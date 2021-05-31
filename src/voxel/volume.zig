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

const Thread = std.Thread;

pub const VolumeThreadGroup = struct {

    allocator: *Allocator,
    volume: *Volume,
    threads: []*Thread,
    mutex: std.Mutex,
    iterator: Volume.Iterator,
    chunk_callback: ChunkCallback,

    const Self = @This();
    
    pub const ChunkCallback = fn(*Chunk) void;

    pub fn init(allocator: *Allocator, volume: *Volume, chunk_callback: ChunkCallback) !*Self {
        const self = try allocator.create(Self);
        const thread_count = Thread.cpuCount() catch 4;
        const threads = try allocator.alloc(*Thread, thread_count);
        self.allocator = allocator;
        self.volume = volume;
        self.threads = threads;
        self.mutex = .{};
        self.iterator = volume.getChunkIterator();
        self.chunk_callback = chunk_callback;
        var i: usize = 0;
        while (i < thread_count) : (i += 1) {
            threads[i] = try Thread.spawn(self, threadFn);
        }
        return self;
    }

    pub fn wait(self: *Self) void {
        for (self.threads) |thread| {
            thread.wait();
        }
    }

    pub fn deinit(self: *Self) void {
        self.wait();
        self.allocator.free(self.threads);
        self.allocator.destroy(self);
    }

    fn threadFn(self: *Self) !void {
        while (self.getNext()) |chunk| {
            // std.log.info("{d}: {d}", .{Thread.getCurrentId(), chunk.position});
            self.chunk_callback(chunk);
        }
    }

    fn getNext(self: *Self) ?*Chunk {
        const held = (&self.mutex).acquire();
        const next = (&self.iterator).next();
        held.release();
        return next;
    }

};