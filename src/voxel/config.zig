const std = @import("std");
const root = @import("root");

pub const Config = struct {
    chunk_subdivisions: usize,
    voxel_width: f32,
};

const config = if (@hasDecl(root, "voxel_config") and @TypeOf(root.voxel_config) == Config)
    root.voxel_config
else
    @compileError(
        \\ no voxel config found in root package. declare it in your root file:
        \\
        \\ const voxel = @import("voxel");
        \\
        \\ pub const voxel_config = voxel.Config {
        \\     // configure here
        \\ };
        \\
    );

comptime {
    if (chunk_subdivisions > 8) {
        @compileError("chunk_subdivisions must be not exceed 8");
    }
    if (voxel_width <= 0) {
        @compileError("voxel width must be greater than 0");
    }
}

pub const exports = struct {

    pub const voxel = struct {
        /// width of a voxel in scene units (commonly meters)
        pub const width: f32 = config.voxel_width;
    };

    pub const chunk = struct {
        /// number of octree subdivisions. even when not using them, it is useful to go with a power of 2
        pub const subdivisions: usize = config.chunk_subdivisions;
        /// width of a chunk in voxels: 2 ^ chunk.subdivisions
        pub const width_voxels: usize = 1 << subdivisions;
        /// width of a chunk in units: chunk.width_voxels * voxel.width
        pub const width_units: f32 =  width_voxels * voxel.width;

    };

};


pub usingnamespace exports;