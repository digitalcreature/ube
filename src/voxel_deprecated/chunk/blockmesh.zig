const std = @import("std");
const math = @import("math");
const gl = @import("gl");

usingnamespace math.glm;
usingnamespace @import("../types.zig");
usingnamespace @import("../chunk.zig");
usingnamespace @import("mesh.zig");

const Cardinal = Coords.Cardinal;

const BlockFaceVertex = extern struct {
    uv: Vec2,
};

pub const BlockFaceInstance = extern struct {
    encoded_position: u32,
    encoded_light: u32,
    material_id: u32,
};

pub const BlockMesh = Mesh(BlockFaceInstance);

const BlockMesher = Mesher(BlockFaceInstance);

fn generateInstancesFromVoxel(mesher: *BlockMesher, voxel: Voxel, chunk: *const Chunk, index: usize) !void {
    if (voxel != 0) {
        const gv = GeneratingVoxel.init(chunk, index);
        comptime var dir = 0;
        inline while (dir < 6) : (dir += 1) {
            const face = gv.Face(@intToEnum(Cardinal, dir));
            if (face.getNeighborVoxel()) |neighbor| {
                if (neighbor == 0) {
                    try mesher.instances.append(createInstanceFromFace(voxel, dir, face));
                }
            }
        }
    }
}

fn createInstanceFromFace(voxel: Voxel, comptime dir: Cardinal, face: GeneratingVoxel.Face(dir)) BlockFaceInstance {
    const gv = face.gv;
    const x = @intCast(u32, gv.coords.x);
    const y = @intCast(u32, gv.coords.y);
    const z = @intCast(u32, gv.coords.z);
    return BlockFaceInstance{
        .encoded_position = x | y << 8 | z << 16 | @enumToInt(dir) << 24,
        .encoded_light = calculateEncodedLight(chunk, dir, pos),
        .material_id = voxel - 1,
    };
}

fn calculateEncodedLight(comptime dir: Cardinal, face: GeneratingVoxel.Face(dir)) u32{
    var encoded_light: u32 = 0;
    comptime var vertex_id: usize = 0;
    inline while (vertex_id < 4) : (vertex_id += 1) {
        encoded_light |= calculateEncodedLightVertex(dir, face, vertex_id) << 8 * vertex_id;
    }
    return encoded_light;
}


fn calculateEncodedLightVertex(comptime dir: Cardinal, face: GeneratingVoxel.Face(dir), comptime vertex_id: usize) u32 {
    const sign = comptime dir.sign();
    const axis = comptime dir.axis();
    const normal = comptime dir.normal();
    const uv = Mesh.quad_verts[vertex_id].uv;
    const u = switch(sign) {
        .positive => uv.x,
        .negative => uv.y,
    };
    const v = switch(sign) {
        .positive => uv.y,
        .negative => uv.x,
    };
    const u_sign: i32 = if (u > 0) 1 else -1;
    const v_sign: i32 = if (v > 0) 1 else -1;
    const tangent = switch (axis) {
        .x => Coords.init(0, u_sign, 0),
        .y => Coords.init(0, 0, u_sign),
        .z => Coords.init(u_sign, 0, 0),
    };
    const bitangent = switch (axis) {
        .x => Coords.init(0, 0, v_sign),
        .y => Coords.init(v_sign, 0, 0),
        .z => Coords.init(0, v_sign, 0),
    };

    const neighbor_coords = coords.add(normal);
    const corner_coords = neighbor_coords.add(tangent).add(bitangent);
    const side_a_coords = neighbor_coords.add(tangent);
    const side_b_coords = neighbor_coords.add(bitangent);
    const corner = (getNeighborVoxelFromCoords(chunk, corner_coords) orelse 0) != 0;
    const side_a = (getNeighborVoxelFromCoords(chunk, side_a_coords) orelse 0) != 0;
    const side_b = (getNeighborVoxelFromCoords(chunk, side_b_coords) orelse 0) != 0;
    var ao: u8 = 0;
    if (side_a and side_b) {
        ao = 3;
    }
    else {
        if (corner) ao += 1;
        if (side_a or side_b) ao += 1;
    }
    return ao;
}


const GeneratingVoxel = struct {

    chunk: *const chunk,
    index: usize,
    coords: Coords,

    pub fn init(chunk: *const Chunk, index: usize) GeneratingVoxel {
        return GeneratingVoxel{
            .chunk = chunk,
            .index = index,
            .coords = Chunk.VoxelData.indexToCoordsFast(index),
        };
    }

    pub fn face(self: GeneratingVoxel, comptime dir: Cardinal) Face(dir) {
        return Face(dir).init(self);
    }

    pub fn Face(comptime dir: Cardinal) type {
        return struct {

            gv: GeneratingVoxel,
            is_edge: bool,

            pub const direction: Cardinal = dir;

            pub fn init(gv: GeneratingVoxel) @This() {
                return .{
                    .gv = gv,
                    .is_edge = switch (dir.sign()) {
                        .positive => gv.coords.get(dir.axis()) == Chunk.width - 1,
                        .negative => gv.coords.get(dir.axis()) == 0,
                    }
                };
            }

            pub fn getNeighborVoxel(self: @This()) ?Voxel {
                if (self.is_edge) {
                    if (self.gv.chunk.neighbors.get(dir)) |neighbor_chunk| {
                        var neighbor_index = self.gv.index;
                        switch (dir) {
                            .x_p => neighbor_index -= (Chunk.width - 1),
                            .y_p => neighbor_index -= (Chunk.width2 - 1),
                            .z_p => neighbor_index -= (Chunk.width3 - 1),
                            .x_n => neighbor_index += (Chunk.width - 1),
                            .y_n => neighbor_index += (Chunk.width2 - 1),
                            .z_n => neighbor_index += (Chunk.width3 - 1),
                        }
                        return neighbor_chunk.voxels.data[neighbor_index];
                    }
                    else {
                        return null;
                    }
                }
                else {
                    const neighbor_index = switch (dir) {
                        .x_p => index + 1,
                        .y_p => index + Chunk.width,
                        .z_p => index + Chunk.width2,
                        .x_n => index - 1,
                        .y_n => index - Chunk.width,
                        .z_n => index - Chunk.width2,
                    };
                    return self.gv.chunk.voxels.data[neighbor_index];
                }
            }

        };
    }

};

