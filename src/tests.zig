const std = @import("std");

const expect = std.testing.expect;

const math = @import("ube/math/math.zig");
usingnamespace math.vector;

fn printFieldInfo(comptime T : type) void {
    const info = @typeInfo(T);
    switch (info) {
        .Struct => {
            if (info.Struct.layout == .Extern) {
                std.log.info("struct {s}: stride {d} bytes", .{@typeName(T), @sizeOf(T)});
                const fields = info.Struct.fields;
                inline for (fields) |field, i| {
                    const offset = @byteOffsetOf(T, field.name);
                    std.log.info("field {d}: {s} (+{d} bytes)", .{i, field.name, offset});
                }
            }
            else {
                @compileError("only extern structs allowed");
            }
        },
        else => @compileError("only structs allowed")
    }
}

test "struct reflection" {
    std.testing.log_level = std.log.Level.info;
    const Vertex = extern struct {
        position : V3f, normal : V3f, uv : V2f,
    };
    var vert = Vertex{
        .position = v3f(15, -2, 7),
        .normal = v3f(-1, 0, 0),
        .uv = v2f(0, 1)
    };
    printFieldInfo(Vertex);
}

fn print_array_info(val : anytype) void {
    const T = @TypeOf(val);
    switch (@typeInfo(T)) {
        .Array => |array| {
            std.log.info("Array [{d}]{s}", .{array.len, @typeName(array.child)});
        },
        .Pointer => |pointer| {
            switch (pointer.size) {
                .One => {
                    std.log.info("Pointer to {s}", .{@typeName(pointer.child)});
                },
                .Slice => {
                    std.log.info("Slice of {s} len {d}", .{@typeName(pointer.child), val.len});
                },
                else => {
                    std.log.info("Other Pointer of {s} ({s})", .{@typeName(pointer.child), @tagName(pointer.size)});
                }
            }
        },
        else => @compileError("only pointer and array types supported"),
    }
}

fn get_ptr(val: anytype) *const c_void {
    const T = @TypeOf(val);
    switch (@typeInfo(T)) {
        .Pointer => |pointer| {
            return @ptrCast(*const c_void, val);
        },
        else => @compileError("only pointer types supported " ++ @typeName(T)),
    }
}

fn get_len(val: anytype) usize {
    const T = @TypeOf(val);
    return switch (@typeInfo(T)) {
        .Pointer => |pointer| switch (pointer.size) {
            .One => switch (@typeInfo(pointer.child)) {
                .Array => |array| array.len,
                else => @compileError("only slices or array pointers are supported " ++ @typeName(T)),
            },
            .Slice => val.len,
            else => @compileError("only slices or array pointers are supported " ++ @typeName(T)),
        },
        else => @compileError("only slicers or array pointers types supported " ++ @typeName(T)),
    };
}

fn print_len(val : anytype) void {
    std.log.info("len of {s} = {d}", .{@typeName(@TypeOf(val)), get_len(val)});
}

fn expect_equal_pointers(a : anytype, b : anytype) void {
    expect(@ptrToInt(get_ptr(a)) == @ptrToInt(get_ptr(b)));
}

pub fn main() void {
    const v = v3f(1, 2, 3);
    std.log.info("{d}", .{v});
}

test "type stuff" {
    std.testing.log_level = std.log.Level.info;
    const array = [_]u8 {1, 45, 32, 8, 3};
    var ptr : [] const u8 = undefined;
    ptr = array[1..4];
    print_len(&array);
    print_len(array[0..2]);
    print_len(ptr);

    expect_equal_pointers(&array, array[0..2]);
    expect_equal_pointers(&array[1], ptr);

}