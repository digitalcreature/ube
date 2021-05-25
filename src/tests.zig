const std = @import("std");
const expect = std.testing.expect;

const builtin = @import("builtin");

fn createStruct() type {
    const foo: i32 = 12;
    const bar: f32 = 0.5;
    var info: builtin.TypeInfo = .{
        .Struct = .{
            .layout = .Auto,
            .fields = &[_]builtin.TypeId.StructField{
                builtin.TypeId.StructField{
                    .name = "foo",
                    .field_type = i32,
                    .default_value = foo,
                    .is_comptime = false,
                    .alignment = @alignOf(i32),
                },
                builtin.TypeId.StructField{
                    .name = "bar",
                    .field_type = f32,
                    .default_value = null,
                    .is_comptime = false,
                    .alignment = @alignOf(f32),
                },
            },
            .decls = &[_]builtin.TypeId.Declaration { },
            .is_tuple = false,
        }
    };
    return @Type(info);
}

test "reified struct" {
    const T = createStruct();
    var x: T = .{ .bar = 0.5 };
    std.testing.expectEqual(x.foo, 12);
    std.testing.expectEqual(x.bar, 0.5);
}