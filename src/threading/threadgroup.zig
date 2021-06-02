const std = @import("std");
const Thread = std.Thread;
const Mutex = Thread.Mutex;
const Allocator = std.mem.Allocator;

pub const fallback_cpu_count: usize = 4;
var cpu_count: ?usize = null;

fn GeneratorFn(comptime State: type, comptime Item: type) type {
    return fn(State) anyerror!?Item;
}

fn TaskFn(comptime State: type, comptime Item: type) type {
    return fn(State, Item) anyerror!void;
}

// const GeneratorInfo = struct {
//     ArgType: type,
//     ReturnType: type,
// };

// fn generatorInfo(comptime GeneratorFn: type) GeneratorInfo {
//     switch (@typeInfo(GeneratorFn)) {
//         .Fn => |Fn| {

//             if (Fn.args.len != 1) @compileError("generator fn must have a single argument");
//             if (Fn.args[0].arg_type == null) @compileError("generator fn argument must not be inferred");
//             const ArgType = Fn.args[0].arg_type.?;

//             if (Fn.return_type == void) @compileError("generator fn must not return void");
//             if (Fn.return_type == null) @compileError("generator fn must have a declared return type");
//             const ReturnType = Fn.return_type.?;

//             switch (@typeInfo(ReturnType)) {
//                 .ErrorUnion => |ErrorUnion| {
//                     if (ErrorUnion.payload == void) @compileError("generator fn must not return void");
//                     switch(@typeInfo(ErrorUnion.payload)) {
//                         .Optional => {
//                             return GeneratorInfo{
//                                 .ArgType = ArgType,
//                                 .ReturnType = ReturnType,
//                             };
//                         },
//                         else => @compileError("generator fn must return an optional"),
//                     }
//                 },
//                 else => @compileError("generator fn must return an error union"),
//             }
//         }
//     }
// }

pub fn ThreadGroup(
        comptime state_type: type,
        comptime item_type: type,
        comptime generator: GeneratorFn(state_type, item_type),
        comptime task: TaskFn(state_type, item_type),
        comptime config: struct {
            use_mutex: bool = true,
        },) type {

    const emptyMixin = struct {
        pub fn emptyMixinFn(comptime Self: type) type {
            return struct{};
        }
    }.emptyMixinFn;
    return ThreadGroupBase(state_type, item_type, generator, task, config, emptyMixin);
}
pub fn ThreadGroupBase(
        comptime state_type: type,
        comptime item_type: type,
        comptime generator: GeneratorFn(state_type, item_type),
        comptime task: TaskFn(state_type, item_type),
        comptime config: struct {
            use_mutex: bool = true,
        },
        comptime mixin: fn(type) type,
    ) type {

    return struct {

        allocator: *Allocator,
        state: State,
        threads: []*Thread,
        mutex: (if (config.use_mutex) Mutex else u8) = (if (config.use_mutex) Mutex{} else 0),

        pub const State = state_type;
        pub const Item = item_type;

        const Self = @This();

        pub usingnamespace mixin(Self);

        pub fn initWithState(allocator: *Allocator, state: State) !Self {
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
                .state = state,
                .threads = try allocator.alloc(*Thread, thread_count),
            };
        }
        
        pub fn deinit(self: *Self) void {
            self.allocator.free(self.threads);
            if (@hasDecl(State, "deinitThreadGroupState")) {
                self.state.deinitThreadGroupState(self.allocator);
            }
        }

        pub fn spawn(self: *Self) !void {
            for (self.threads) |*thread| {
                thread.* = try Thread.spawn(threadFn, self);
            }
        }

        pub fn wait(self: *Self) void {
            for (self.threads) |thread| {
                thread.wait();
            }
        }

        fn wrappedGenerator(self: *Self) !?Item {
            if (config.use_mutex) {
                var held = self.mutex.acquire();
                defer held.release();   // use defer here so we still release the mutex if we get an error
                const item = try generator(self.state);
                return item;
            }
            else {
                return generator(self.state);
            }
        }

        fn threadFn(self: *Self) !void {
            while (try wrappedGenerator(self)) |item| {
                try task(self.state, item);
            }
        }

    };
}