const std = @import("std");
const Thread = std.Thread;
const Mutex = std.Mutex;
const Allocator = std.mem.Allocator;

var cpu_count: ?usize = null;

pub fn TaskFn(comptime Item: type) type {
    return fn(Item) anyerror!void;
}

pub fn GetIteratorFn(comptime Collection: type, comptime Iterator: type) type {
    return fn(*Collection) Iterator;
}

pub fn AtomicStaticIterator(comptime Collection: type, comptime Item: type, comptime Iterator: type, comptime getIterator: GetIteratorFn(Collection, Iterator)) type {
    const NextFn = fn (*Iterator) ?Item;
    if (!@hasDecl(Iterator, "next") or @TypeOf(Iterator.next) != NextFn) {
        const iter_name = @typeName(Iterator);
        const item_name = @typeName(Item);
        @compileError("iterator type " ++ iter_name ++ " must have a decl `pub fn next(self: *" ++ iter_name ++ ") ?" ++ item_name++ "`");
    }

    return struct {

        collection: *Collection,
        iterator: Iterator,
        mutex: Mutex,
        

        const Self = @This();

        pub fn init(collection: *Collection) Self {
            return .{
                .collection = collection,
                .iterator = getIterator(collection),
                .mutex = .{},
            };
        }

        pub fn next(self: *Self) ?Item {
            const held = self.mutex.acquire();
            const item = self.iterator.next();
            held.release();
            return item;
        }

    };

}

pub fn ThreadGroupStatic(comptime Collection: type, comptime Item: type, comptime Iterator: type, comptime getIterator: GetIteratorFn(Collection, Iterator), comptime taskFn: TaskFn(Item)) type {
    const StaticIterator = AtomicStaticIterator(Collection, Item, Iterator, getIterator);
    return ThreadGroup(Collection, Item, StaticIterator, StaticIterator.init, taskFn);
}

pub fn ThreadGroup(comptime Collection: type, comptime Item: type, comptime Iterator: type, comptime getIterator: GetIteratorFn(Collection, Iterator), comptime taskFn: TaskFn(Item)) type {

    return struct {

        allocator: *Allocator,
        collection: *Collection,
        threads: []*Thread,
        iterator: Iterator,

        const Self = @This();

        pub const fallback_cpu_count = 4;

        pub fn init(allocator: *Allocator, collection: *Collection) !Self {
            if (cpu_count == null) {
                if (Thread.cpuCount()) |count| {
                    cpu_count = count;
                }
                else |err| {
                    std.log.warn("unable to get cpu count, using fallback ({d}) for thread count [error: {s}]", .{fallback_cpu_count, @errorName(err)});
                    cpu_count = fallback_cpu_count;
                }
            }
            const thread_count = cpu_count.?;
            return Self{
                .allocator = allocator,
                .collection = collection,
                .threads = try allocator.alloc(*Thread, thread_count),
                .iterator = getIterator(collection),
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.threads);
        }

        pub fn spawn(self: *Self) !void {
            for (self.threads) |*thread| {
                thread.* = try Thread.spawn(self, threadFn);
            }
        }

        pub fn wait(self: *Self) void {
            for (self.threads) |thread| {
                thread.wait();
            }
        }


        fn threadFn(self: *Self) !void {
            while (self.iterator.next()) |item| {
                try taskFn(item);
            }
        }

    };

}