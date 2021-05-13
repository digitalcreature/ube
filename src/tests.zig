const std = @import("std");
const expect = std.testing.expect;

const M = [3][2]f32;

test "array rank" {
    var m: M = undefined;
    const info = @typeInfo(M);
    expect(info.Array.len == 3);
    const info2 = @typeInfo(info.Array.child);
    expect(info2.Array.len == 2);
    expect(info2.Array.child == f32);
}
