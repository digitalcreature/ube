const std = @import("std");
const Thread = std.Thread;
const Queue =  std.atomic.Queue;
const Allocator = std.mem.Allocator;

pub fn TaskGroup(comptime State: type, comptime taskFn: fn(*State) !void) type {

    return struct {

        threads: [thread_count]*Thread,

        pub const thread_count = 8;

        const Self = @This();

        pub fn init(self: *Self, allocator: *Allocator) void {
            comptime var i = 0;
            inline while (i < thread_count) : (i += 1) {
                self.threads[i] = Thread.spawn(self, threadFn);
            }
        }

        fn threadFn(group: *Self) !void {

        }

        pub const Task = struct {

        };

    };

}