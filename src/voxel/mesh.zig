const std = @import("std");
const math = @import("math");
const gl = @import("gl");

usingnamespace @import("types.zig");
usingnamespace math.glm;
usingnamespace @import("chunk.zig");
const shaders = @import("shaders");

const Allocator = std.mem.Allocator;

pub const VoxelsUniforms = struct {
    proj: gl.Uniform(Mat4),
    view: gl.Uniform(Mat4),
    model: gl.Uniform(Mat4),
    voxel_size: gl.Uniform(f32),
    light_dir: gl.Uniform(Vec3),
    albedo: gl.UniformTextureUnit,
};

pub fn loadVoxelsShader() !gl.Program(VoxelsUniforms) {
    return try shaders.loadShader(VoxelsUniforms, "voxels");
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
    };

    pub const QuadInstanceBuffer = gl.VertexBuffer(QuadInstance);

    const VertBufferBindings = struct {
        quad: gl.VertexBufferBind(QuadVert, .{.bind_index = 0, .attrib_start = 0}),
        quad_instances: gl.VertexBufferBind(QuadInstance, .{.bind_index = 1, .attrib_start = 1, .divisor = 1}),
    };

    pub const VAO = gl.VertexArrayExt(VertBufferBindings, u32, VAOMixin);
    
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
        
        comptime var f: u32 = 0;
        inline while (f < 6) : (f += 1) {
            const face = @intToEnum(Face, f);
            if (!isEdge(loc, face)) {
                const neighbor_loc = loc.add(face.normal());
                const neighbor = voxels.get(neighbor_loc);
                const needs_face = (neighbor == 0);
                if (needs_face) {
                    const instance: ChunkMesh.QuadInstance = .{
                        .encoded_position = x | y << 8 | z << 16 | f << 24,
                        .encoded_light = calculateEncodedLight(chunk, face, loc),
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
        encoded_light |= calculateEncodedLightVertex(chunk, face, coords, vertex_id) << 8 * vertex_id;
    }
    return encoded_light;
}

fn calculateEncodedLightVertex(chunk: Chunk, comptime face: Face, coords: Coords, comptime vertex_id: usize) u32 {
    const sign = comptime face.sign();
    const axis = comptime face.axis();
    const normal = comptime face.normal();
    const uv = ChunkMesh.quad_verts[vertex_id].uv;
    const u = switch(sign) {
        .pos => uv.x,
        .neg => uv.y,
    };
    const v = switch(sign) {
        .pos => uv.y,
        .neg => uv.x,
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
    const corner = if (Chunk.coordsAreInBounds(corner_coords)) (chunk.voxels.get(corner_coords) == 1) else false;
    const side_a = if (Chunk.coordsAreInBounds(side_a_coords)) (chunk.voxels.get(side_a_coords) == 1) else false;
    const side_b = if (Chunk.coordsAreInBounds(side_b_coords)) (chunk.voxels.get(side_b_coords) == 1) else false;
    var ao: u8 = 0;
    if (side_a and side_b) {
        ao = 1;
    }
    else {
        if (corner) ao += 1;
        if (side_a) ao += 1;
        if (side_b) ao += 1;
    }
    return ao;
}

fn isEdge(coords: Coords, comptime face: Face) bool {
    return switch (face.sign()) {
        .pos => face.coord(coords) == Chunk.width - 1,
        .neg => face.coord(coords) == 0,
    };
}

const Face = enum(u32) {
    x_p = 0,
    y_p = 1,
    z_p = 2,
    x_n = 3,
    y_n = 4,
    z_n = 5,
    
    pub const Sign = enum { pos, neg };
    pub const Axis = enum(usize) { x = 0, y = 1, z = 2 };

    pub fn sign(self: Face) Sign {
        return if (@enumToInt(self) >= 3) .neg else .pos;
    }

    pub fn axis(self: Face) Axis {
        return switch (self.sign()) {
            .pos => @intToEnum(Axis, @enumToInt(self)),
            .neg => @intToEnum(Axis, @enumToInt(self) - 3),
        };
    }

    pub fn signFloat(self: Face) f32 {
        return switch (self.sign()) {
            .pos => 1,
            .neg => -1,
        };
    }

    pub fn coord(comptime self: Face, coords: Coords) i32 {
        return coords.get(@enumToInt(comptime self.axis()));
    }

    pub fn normal(comptime self: Face) Coords {
        return Coords.uniti(@enumToInt(self));
    }

};