const std = @import("std");
const root = @import("root");

pub const config : Config = if (@hasDecl(root, "voxel_config") and @TypeOf(root.voxel_config) == Config)
    root.voxel_config
else
    @compileError("root file is missing public voxel configuration (pub const voxel_config : voxel.Config)");

fn checkChunkWidth() bool {
    const width = config.chunk_width;
    if (width > 256 or width == 0) {
        return false;
    }
    return std.math.isPowerOfTwo(config.chunk_width);
}

comptime {
    if (!checkChunkWidth()) {
        @compileError("chunk width must be nonzero power of two no greater than 256");
    }
}

pub const Config = struct {
    voxel_size : f32,
    chunk_width : usize,
};