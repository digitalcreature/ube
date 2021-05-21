pub const Config = struct {
    voxel_size : f32,
    chunk_width : u8,
};

const root = @import("root");
const std = @import("std");

pub const config : Config = if (@hasDecl(root, "voxel_config") and @TypeOf(root.voxel_config) == Config)
    root.voxel_config
else
    @compileError("root file is missing public voxel configuration (pub const voxel_config : voxel.Config)");