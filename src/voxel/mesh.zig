const std = @import("std");
const math = @import("math");
const gl = @import("gl");

usingnamespace @import("types.zig");
usingnamespace math.glm;
usingnamespace @import("chunk.zig");
const shaders = @import("shaders");

const Allocator = std.mem.Allocator;

const CameraUniformDecl = struct {
    proj: Mat4,
    view: Mat4,
};

pub const VoxelsUniformDecls = &[_]type{
    CameraUniformDecl, 
    struct {
        model: Mat4,
        voxel_size: f32,
        light_dir: Vec3,
        albedo: i32,
    },
};

pub fn loadVoxelsShader() !gl.Program(VoxelsUniformDecls) {
    return try shaders.loadShader(VoxelsUniformDecls, "voxels");
}

pub const ChunkMesh = struct {

    vbo: QuadInstanceBuffer,
    quad_instances: std.ArrayList(QuadInstance),

    const Self = @This();

    pub fn init(allocator: *Allocator) Self {
        return .{
            .vbo = QuadInstanceBuffer.init(),
            .quad_instances = std.ArrayList(QuadInstance).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.*.vbo.deinit();
        self.*.quad_instances.deinit();
    }

    pub const generate = generateChunkMesh;

    pub fn updateBuffer(self: Self) void {
        self.vbo.data(self.quad_instances.items, .StaticDraw);
    }


    const QuadVert = extern struct {
        uv: Vec2,
    };

    pub const QuadInstance = extern struct {
        encoded_position: u32,
        encoded_light: u32,
        material_id: u32,
    };

    pub const QuadInstanceBuffer = gl.VertexBuffer(QuadInstance);

    const VertBufferBindings = struct {
        quad: gl.VertexBufferBind(QuadVert, .{.bind_index = 0, .attrib_start = 0}),
        quad_instances: gl.VertexBufferBind(QuadInstance, .{.bind_index = 1, .attrib_start = 1, .divisor = 1}),
    };

    pub const VAO = gl.VertexArrayExt(VertBufferBindings, u32, VAOMixin);
    

    // 0 --- 1
    // | \   |
    // |  \  |
    // |   \ |
    // 2 --- 3
    // 
    // v+
    // |
    // 0 -- u+
    const quad_verts = [4]QuadVert{ 
        .{ .uv = vec2(0, 1) }, 
        .{ .uv = vec2(1, 1) }, 
        .{ .uv = vec2(0, 0) }, 
        .{ .uv = vec2(1, 0) },
    };

    pub fn initVAO() VAO {
        var vao = VAO.init();
        const indices : [6]u32 = .{ 0, 1, 3, 0, 3, 2};
        var ibo = gl.IndexBuffer32.initData(&indices, .StaticDraw);
        vao.bindIndexBuffer(ibo);
        var quad_vbo = gl.VertexBuffer(QuadVert).initData(&quad_verts, .StaticDraw);
        vao.vertices.quad.bindBuffer(quad_vbo);
        return vao;
    }

};

fn VAOMixin(comptime VAO: type) type {
    return struct {
        pub fn on_deinit(self: VAO) void {
            self.deinitBoundIndexBuffer();
            self.vertices.quad.deinitBoundBuffer();
        }
    };
}

fn generateChunkMesh(self: *ChunkMesh, chunk: Chunk) !void {
    const voxels = &chunk.voxels;
    const width = Chunk.width;
    
    var x: u32 = 0; while (x < width) : (x += 1) {
    var y: u32 = 0; while (y < width) : (y += 1) {
    var z: u32 = 0; while (z < width) : (z += 1) {
        
        const loc = autoVec(.{x, y, z}).intCast(Coords);
        const voxel = voxels.get(loc);
        
        if (voxel == 0) {
            continue;
        }
        const material_id: u32 = voxel - 1;
        
        comptime var f: u32 = 0;
        inline while (f < 6) : (f += 1) {
            const face = @intToEnum(Face, f);
            if (getNeighborVoxel(chunk, face, loc)) |neighbor| {
                const needs_face = (neighbor == 0);
                if (needs_face) {
                    const instance: ChunkMesh.QuadInstance = .{
                        .encoded_position = x | y << 8 | z << 16 | f << 24,
                        .encoded_light = calculateEncodedLight(chunk, face, loc),
                        .material_id = material_id,
                    };
                    try self.*.quad_instances.append(instance);
                }
            }
        }
    }}}
    std.log.info("generated chunk mesh with {d} quads", .{self.*.quad_instances.items.len});
}

fn calculateEncodedLight(chunk: Chunk, comptime face: Face, coords: Coords) u32{
    var encoded_light: u32 = 0;
    comptime var vertex_id: usize = 0;
    inline while (vertex_id < 4) : (vertex_id += 1) {
        encoded_light |= calculateEncodedLightVertex(chunk, face, coords, @intToEnum(QuadVertId, vertex_id)) << 8 * vertex_id;
    }
    return encoded_light;
}

fn calculateEncodedLightVertex(chunk: Chunk, comptime face: Face, coords: Coords, comptime vertex_id: QuadVertId) u32 {
    const sign = comptime face.sign();
    const axis = comptime face.axis();
    const normal = comptime face.normal();
    const uv = ChunkMesh.quad_verts[@enumToInt(vertex_id)].uv;
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

fn getNeighborVoxelFromCoords(chunk: Chunk, coords: Coords) ?VoxelTypeId {
    if(chunk.getNeighborCoords(coords)) |neighbor| {
        return neighbor.chunk.voxels.get(neighbor.coords);
    }
    else {
        return null;
    }
}

fn isEdge(coords: Coords, comptime face: Face) bool {
    return switch (face.sign()) {
        .positive => face.coord(coords) == Chunk.width - 1,
        .negative => face.coord(coords) == 0,
    };
}

fn getNeighborVoxel(chunk: Chunk, comptime face: Face, local_coords: Coords) ?VoxelTypeId {
    if (!isEdge(local_coords, face)) {
        return chunk.voxels.get(local_coords.add(face.normal()));
    }
    else {
        const neighbor_chunk_opt = chunk.neighbors[@enumToInt(face)];
        if (neighbor_chunk_opt) |neighbor_chunk| {
            var neighbor_coords = local_coords.add(face.normal());
            switch (face.sign()) {
                .positive => neighbor_coords.set(@enumToInt(comptime face.axis()), 0),
                .negative => neighbor_coords.set(@enumToInt(comptime face.axis()), Chunk.width - 1),
            }
            return neighbor_chunk.voxels.get(neighbor_coords);
        }
        else {
            return null;
        }
    }
}


// 0 --- 1
// | \   |
// |  \  |
// |   \ |
// 2 --- 3
// 
// v+
// |
// 0 -- u+
const QuadVertId = enum(u2) {
    np = 0,
    pp = 1,
    nn = 2,
    pn = 3,
};

const Face = enum(u32) {
    x_p = 0,
    y_p = 1,
    z_p = 2,
    x_n = 3,
    y_n = 4,
    z_n = 5,
    
    pub const Sign = enum { positive = 0, negative = 1 };
    pub const Axis = enum(usize) { x = 0, y = 1, z = 2 };

    pub fn init(axis: Axis, sign: Sign) Face {
        return @intToEnum(Face, @enumToInt(axis) + (@enumToInt(sign) * 3));
    }

    pub fn sign(self: Face) Sign {
        return if (@enumToInt(self) >= 3) .negative else .positive;
    }

    pub fn axis(self: Face) Axis {
        return switch (self.sign()) {
            .positive => @intToEnum(Axis, @enumToInt(self)),
            .negative => @intToEnum(Axis, @enumToInt(self) - 3),
        };
    }

    pub fn signFloat(self: Face) f32 {
        return switch (self.sign()) {
            .positive => 1,
            .negative => -1,
        };
    }

    pub fn coord(comptime self: Face, coords: Coords) i32 {
        return coords.get(@enumToInt(comptime self.axis()));
    }

    pub fn normal(comptime self: Face) Coords {
        return Coords.uniti(@enumToInt(self));
    }

};