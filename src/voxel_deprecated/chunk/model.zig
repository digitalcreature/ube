const std = @import("std");
const math = @import("math");
const gl = @import("gl");

usingnamespace math.glm;
usingnamespace @import("../chunk.zig");
usingnamespace @import("../types.zig");
usingnamespace @import("mesh.zig");
usingnamespace @import("blockmesh.zig");

const Allocator = std.mem.Allocator;

pub const Model = struct {

    allocator: *Allocator,
    block_mesh: ?BlockMesh = null,

    const Self = @This();

    pub fn init(allocator: *Allocator) Self {
        return Self{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {}

};
