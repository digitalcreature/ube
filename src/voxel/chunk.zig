const std = @import("std");
const math = @import("math");

usingnamespace @import("types.zig");
usingnamespace math.glm;

const config = @import("config.zig").config;

const Volume = @import("volume.zig").Volume;
const ChunkMesh = @import("mesh.zig").ChunkMesh;

pub const Chunk = struct {
    volume: *Volume,
    position: Coords,
    voxels: Voxels,
    neighbors: Neighbors = std.mem.zeroes(Neighbors),
    mesh: ?*ChunkMesh = null,

    const Neighbors = [6]?*Self;

    pub const Voxels = DataArray(VoxelTypeId);

    const Self = @This();

    pub const width = config.chunk_width;
    pub const edge_distance = @intToFloat(f32, config.chunk_width) * config.voxel_size;

    pub fn init(volume: *Volume, position: Coords) Self {
        return .{
            .volume = volume,
            .position = position,
            .voxels = Voxels.init(),
        };
    }

    pub fn deinit(self: Self) void {
        self.voxels.deinit();
    }

    pub fn coordsAreInBounds(coords: Coords) bool {
        return (coords.x < width and coords.y < width and coords.z < width) and
            (coords.x >= 0 and coords.y >= 0 and coords.z >= 0);
    }

    pub const QualifiedCoords = struct { chunk: *const Self, coords: Coords };

    pub fn getNeighborCoords(self: *const Self, coords: Coords) ?QualifiedCoords {
        if (coordsAreInBounds(coords)) {
            return QualifiedCoords{
                .chunk = self,
                .coords = coords,
            };
        }
        var x = coords.x;
        var y = coords.y;
        var z = coords.z;
        const w = @intCast(i32, width);
        // check x
        if (x >= width) {
            if (self.neighbors[0]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x - w, y, z));
            }
        } else if (x < 0) {
            if (self.neighbors[3]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x + w, y, z));
            }
        }
        // check y
        if (y >= width) {
            if (self.neighbors[1]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x, y - w, z));
            }
        } else if (y < 0) {
            if (self.neighbors[4]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x, y + w, z));
            }
        }
        // check z
        if (z >= width) {
            if (self.neighbors[2]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x, y, z - w));
            }
        } else if (z < 0) {
            if (self.neighbors[5]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x, y, z + w));
            }
        }
        return null;
    }

    pub fn DataArray(comptime T: type) type {
        return struct {
            data: Data = std.mem.zeroes(Data),

            pub const Data = [width][width][width]T;

            pub fn init() @This() {
                return .{};
            }

            fn deinit(self: @This()) void {}

            pub fn get(self: @This(), loc: Coords) T {
                const pos = coordsToByteCoords(loc);
                if (std.debug.runtime_safety) {
                    if (loc.x < width and loc.y < width and loc.z < width) {
                        return self.data[pos.x][pos.y][pos.z];
                    }
                    std.debug.panicExtra(null, null, "local coords {d} are out of bounds for chunks of width {d}", .{ loc, width });
                } else {
                    return self.data[pos.x][pos.y][pos.z];
                }
            }

            pub fn set(self: *@This(), loc: Coords, val: T) void {
                const pos = coordsToByteCoords(loc);
                if (std.debug.runtime_safety) {
                    if (loc.x < width and loc.y < width and loc.z < width) {
                        self.*.data[pos.x][pos.y][pos.z] = val;
                    }
                    std.debug.panicExtra(null, null, "local coords {d} are out of bounds for chunks of width {d}", .{ loc, width });
                } else {
                    self.*.data[pos.x][pos.y][pos.z] = val;
                }
            }
        };
    }
};
