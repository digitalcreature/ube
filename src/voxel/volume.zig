const std = @import("std");
const math = @import("math");


usingnamespace @import("types.zig");
usingnamespace math.glm;

const config = @import("config.zig").config;
const Chunk = @import("chunk.zig").Chunk;
const Allocator = std.mem.Allocator;

pub const Volume = struct {
    
    allocator: *Allocator,
    width: usize,
    height: usize,
    depth: usize,
    chunks: []*Chunk,
    chunks_offset: Coords,

    const Self = @This();

    pub fn init(allocator: *Allocator, w: usize, h: usize, d: usize, chunks_offset: Coords) !*Self {
        var self: *Self = try allocator.create(Self);
        self.allocator = allocator;
        self.width = w;
        self.height = h;
        self.depth = d;
        self.chunks_offset = chunks_offset;
        self.chunks = try allocator.alloc(*Chunk, w * h * d);
        var pos = Coords.zero;
        while (pos.x < w) : (pos.x += 1) {
            pos.y = 0;
            while (pos.y < h) : (pos.y += 1) {
                pos.z = 0;
                while (pos.z < d) : (pos.z += 1) {
                    const chunk = try allocator.create(Chunk);
                    chunk.* = Chunk.init(self, pos.add(chunks_offset));
                    const x = @intCast(usize, pos.x);
                    const y = @intCast(usize, pos.y);
                    const z = @intCast(usize, pos.z);
                    const index = x + (y * w) + (z * w * h);
                    self.chunks[index] = chunk;
                }
            }
        }
        var iter = Iterator.init(self);
        while (iter.next()) |chunk| {
            comptime var axis = 0;
            inline while (axis < 6) : (axis += 1) {
                const npos = chunk.position.add(Coords.uniti(axis));
                chunk.neighbors[axis] = self.getChunk(npos);
            }
        }
        return self;
    }

    pub fn deinit(self: *Self) void {
        for (self.chunks) |chunk| {
            self.allocator.destroy(chunk);
        }
        self.allocator.free(self.chunks);
        self.allocator.destroy(self);
    }

    pub fn getChunk(self: Self, coords: Coords) ?*Chunk {
        return self.getChunkDirect(coords.sub(self.chunks_offset));
    }

    pub fn getChunkDirect(self: Self, coords: Coords) ?*Chunk {
        const x = coords.x;
        const y = coords.y;
        const z = coords.z;
        if (x < 0 or x >= self.width or y < 0 or y >= self.height or z < 0 or z >= self.depth) {
            return null;
        }
        const ux = @intCast(usize, x);
        const uy = @intCast(usize, y);
        const uz = @intCast(usize, z);
        const index = ux + (uy * self.width) + (uz * self.width * self.height);
        return self.chunks[index];
    }

    pub fn getChunkIterator(self: *Self) Iterator {
        return Iterator.init(self);
    }

    // TODO: make volume iterator threadsafe (@atomicRead/Write etc)
    // TODO: maybe some way to split iterators across threads in the group?
    pub const Iterator  = struct {
        volume: *Volume,
        pos: Coords,

        pub fn init(volume: *Volume) Iterator {
            return .{
                .volume = volume,
                .pos = Coords.zero,
            };
        }

        pub fn reset(self: *Iterator) void {
            self.pos = Coords.zero;
        }

        pub fn next(self: *Iterator) ?*Chunk {
            const volume = self.volume;
            var pos = self.pos;
            if (pos.z < volume.depth) {
                const out = volume.getChunkDirect(self.pos);
                pos.x += 1;
                if (pos.x >= volume.width) {
                    pos.y += 1;
                    pos.x = 0;
                    if (pos.y >= volume.height) {
                        pos.z += 1;
                        pos.y = 0;
                    }
                }
                self.pos = pos;
                return out;
            }
            else {
                return null;
            }
        }

    };


};

const threading = @import("threading");

pub fn ChunkTaskFn(comptime State: type) type {
    if (State == void) {
        return fn(*Chunk) anyerror!void;
    }
    else {
        return fn(State, *Chunk) anyerror!void;
    }
}

pub fn VolumeThreadGroup(comptime chunkTaskFn: fn(*Chunk) anyerror!void) type {
    return VolumeThreadGroupWithState(void, chunkTaskFn);
}

pub fn VolumeThreadGroupWithState(comptime State: type, comptime chunkTaskFn: ChunkTaskFn(State)) type {

    const StateOrShim = if (State == void) u8 else State;

    const CombinedState = struct {
        volume: *Volume,
        iterator: *Volume.Iterator,
        state: StateOrShim,

        pub fn deinitThreadGroupState(self: *@This(), allocator: *Allocator) void {
            allocator.destroy(self.iterator);
        }
    };

    const generator = struct {
        pub fn generatorFn(state: CombinedState) anyerror!?*Chunk {
            return state.iterator.next();
        }
    }.generatorFn;

    const task = struct {
        pub fn taskFn(state: CombinedState, chunk: *Chunk) anyerror!void {
            if (State == void) {
                try chunkTaskFn(chunk);
            }
            else {
                try chunkTaskFn(state.state, chunk);
            }
        }
    }.taskFn;

    const mixinWithState = struct {
        pub fn mixinWithStateFn(comptime Self: type) type {
            return struct {
                pub fn init(allocator: *Allocator, volume: *Volume, state: StateOrShim) !Self {
                    const iterator = try allocator.create(Volume.Iterator);
                    iterator.* = volume.getChunkIterator();
                    const combined_state = CombinedState{
                        .volume = volume,
                        .iterator = iterator,
                        .state = state,
                    };
                    return Self.initWithState(allocator, combined_state);
                }
            };
        }

    }.mixinWithStateFn;


    const mixin = if (State == void) struct {
        pub fn mixinWithNoStateFn(comptime Self: type) type {
            return struct {
                pub fn init(allocator: *Allocator, volume: *Volume) !Self {
                    return mixinWithState(Self).init(allocator, volume, 0);
                }
            };
        }
    }.mixinWithNoStateFn
    else mixinWithState;

    return threading.ThreadGroupBase(CombinedState, *Chunk, generator, task, .{ .use_mutex = true, }, mixin);
}

pub const VolumeChunkQueue = struct {

    volume: *Volume,
    queue: Queue,


    pub const Queue = threading.Queue(*Chunk);
    const Self = @This();

    pub fn init(allocator: *Allocator, volume: *Volume, capacity: usize) !Self {
        return Self{
            .volume = volume,
            .queue = try Queue.init(allocator, capacity),
        };
    }

    pub fn deinit(self: *Self) void {
        self.queue.deinit();
    }

    pub fn count(self: *Self) usize {
        return self.queue.count();
    }

    pub fn enqueue(self: *Self, chunk: *Chunk) !void {
        return self.queue.enqueue(chunk);
    }

    pub fn dequeue(self: *Self) ?*Chunk {
        return self.queue.dequeue();
    }


};