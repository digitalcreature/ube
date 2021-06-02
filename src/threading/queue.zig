const std = @import("std");
const builtin = @import("builtin");
const os = std.os;
const mem = std.mem;

const Allocator = mem.Allocator;

const cache_line_length = switch (builtin.cpu.arch) {
    .x86_64, .aarch64, .powerpc64 => 128,
    .arm, .mips, .mips64, .riscv64 => 32,
    .s390x => 256,
    else => 64,
};

// multi-producer, multi-consumer atomic queue.
// original implementation by @lithdew, modificated by sam lovelace
pub fn Queue(comptime T: type) type {
    return struct {

        allocator: *Allocator,
        capacity: usize,
        entries: []Entry align(cache_line_length),
        enqueue_pos: usize align(cache_line_length),
        dequeue_pos: usize align(cache_line_length),

        const Self = @This();

        pub const Entry = struct {
            sequence: usize align(cache_line_length),
            item: T,
        };

        pub fn init(allocator: *Allocator, capacity: usize) !Self {
            const entries = try allocator.alloc(Entry, capacity);
            for (entries) |*entry, i| {
                entry.sequence = i;
            }

            return Self {
                .allocator = allocator,
                .capacity = capacity,
                .entries = entries,
                .enqueue_pos = 0,
                .dequeue_pos = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.entries);
        }

        pub fn count(self: *Self) usize {
            const tail = @atomicLoad(usize, &self.dequeue_pos, .Monotonic);
            const head = @atomicLoad(usize, &self.enqueue_pos, .Monotonic);
            return (tail -% head) % self.capacity;
        }

        pub fn enqueue(self: *Self, item: T) !void {
            var entry: *Entry = undefined;
            var pos = @atomicLoad(usize, &self.enqueue_pos, .Monotonic);
            while (true) : (os.sched_yield() catch {}) {
                entry = &self.entries[pos % self.capacity];

                const seq = @atomicLoad(usize, &entry.sequence, .Acquire);
                const diff = @intCast(isize, seq) -% @intCast(isize, pos);
                if (diff == 0) {
                    pos = @cmpxchgWeak(usize, &self.enqueue_pos, pos, pos +% 1, .Monotonic, .Monotonic) orelse {
                        entry.item = item;
                        @atomicStore(usize, &entry.sequence, pos +% 1, .Release);
                        return;
                    };
                } else if (diff < 0) {
                    return error.full;
                } else {
                    pos = @atomicLoad(usize, &self.enqueue_pos, .Monotonic);
                }
            }
        }

        pub fn dequeue(self: *Self) ?T {
            var entry: *Entry = undefined;
            var pos = @atomicLoad(usize, &self.dequeue_pos, .Monotonic);
            while (true) : (os.sched_yield() catch {}) {
                entry = &self.entries[pos % self.capacity];

                const seq = @atomicLoad(usize, &entry.sequence, .Acquire);
                const diff = @intCast(isize, seq) -% @intCast(isize, pos +% 1);
                if (diff == 0) {
                    pos = @cmpxchgWeak(usize, &self.dequeue_pos, pos, pos +% 1, .Monotonic, .Monotonic) orelse {
                        const item = entry.item;
                        @atomicStore(usize, &entry.sequence, pos +% (self.capacity - 1) +% 1, .Release);
                        return item;
                    };
                } else if (diff < 0) {
                    return null;
                } else {
                    pos = @atomicLoad(usize, &self.dequeue_pos, .Monotonic);
                }
            }
        }

    };
}


test "mpmc queue" {
    std.testing.log_level = .debug;
    var queue = try Queue(i32).init(&std.testing.allocator_instance.allocator, 48);
    defer queue.deinit();
    const prod = try std.Thread.spawn(&queue, testProducer);
    const cons = try std.Thread.spawn(&queue, testConsumer);
    prod.wait();
    cons.wait();
}

const count = 512;

fn testProducer(q: *Queue(i32)) !void {
    var i: i32 = 0;
    while (i < count) : (i += 1) {
        std.time.sleep(10_000_000);
        if (q.enqueue(i)) {
            std.log.debug("produced {d}", .{i});
        }
        else |_| {
            std.log.debug("could not produce {d}", .{i});
        }
    }
}

fn testConsumer(q: *Queue(i32)) !void {
    // std.time.sleep(100_000_000);
    var n: i32 = 0;
    while(n < count) {
        while (q.dequeue()) |i| {
            n += 1;
            std.log.debug("consumed {d}", .{i});
        }
    }
}