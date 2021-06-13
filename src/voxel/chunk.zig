const std = @import("std");
const config =  @import("config.zig");

usingnamespace @import("traverse.zig");
usingnamespace @import("voxel.zig");

const Allocator = std.mem.Allocator;

pub const Chunk = struct {

    allocator: *Allocator,

    coords: Coords,
    neighbors: Neighbors = .{ .data = std.mem.zeroes(Neighbors.Data) },
    
    main_voxel_data: ?*MainVoxelData = null,

    pub const Neighbors = Cardinal.IndexedArray(?*Self);
    pub const subdivisions = config.chunk.subdivisions;
    pub const width = config.chunk.width_voxels;

    pub const VoxelData = ChunkVoxelData;

    pub const MainVoxelData = VoxelData(Voxel);

    const Self = @This();

    pub fn init(allocator: *Allocator, coords: Coords) Self {
        return Self {
            .allocator = allocator,
            .coords = coords,
        };
    }

    pub fn deinit(self: *Self) void {
        self.freeMainVoxelData();
    }

    pub fn allocateMainVoxelData(self: *Self) !void {
        if (std.debug.runtime_safety and self.main_voxel_data != null) {
            return error.VoxelDataAlreadyAllocated;
        }
        else {
            self.main_voxel_data = try self.allocator.create(VoxelArray);
        }
    }

    pub fn freeMainVoxelData(self: *Self) void {
        if (self.main_voxel_data) |data| {
            self.allocator.destroy(data);
        }
    }

};

fn ChunkVoxelData(comptime T: type) type {
    return struct {
        
        data: Data,

        pub const width = Chunk.width;

        pub const data_len = width * width * width;
        pub const Data = [data_len]T;

        const Self = @This();

        pub fn get(self: Self, index: LocalIndex) T {
            return self.data[index.tag];
        }

        pub fn getPtr(self: *Self, index: LocalIndex) *T {
            return &self.data[index.tag];
        }

        pub fn set(self: *Self, index: LocalIndex, value: T) void {
            self.data[index.tag] = value;
        }

    };
}