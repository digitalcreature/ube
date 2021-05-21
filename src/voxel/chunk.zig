const std = @import("std");
const math = @import("math");

usingnamespace @import("types.zig");
usingnamespace math.glm;

const config = @import("config.zig").config;

pub const Chunk = struct {

    voxels : Voxels,

    pub const Voxels = DataArray(VoxelTypeID);

    const Self = @This();

    pub const width = config.chunk_width;

    pub fn init() Self {
        return .{
            .voxels = Voxels.init(),
        };
    }

    pub fn deinit(self : Self) void {
        self.voxels.deinit();
    }

    pub fn DataArray(comptime T : type) type {
        return struct {

            data : Data = std.mem.zeroes(Data),

            pub const Data = [width][width][width]T;

            pub fn init() @This() {
                return .{};
            }

            fn deinit(self : @This()) void {}

            pub fn get(self : @This(), loc : Coords) T {
                const pos = coordsToByteCoords(loc) catch @panic("out of bounds coords");
                return self.data[pos.x][pos.y][pos.z];
            }

            pub fn set(self : *@This(), loc : Coords, val : T) void {
                const pos = coordsToByteCoords(loc) catch @panic("out of bounds coords");
                self.*.data[pos.x][pos.y][pos.z] = val;
            }

        };
    }
};


// generic 3d array