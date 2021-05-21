const std = @import("std");
const math = @import("math");
const gl = @import("gl");

usingnamespace @import("types.zig");
usingnamespace math.glm;
usingnamespace @import("chunk.zig");

const Allocator = std.mem.Allocator;


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
        id: u32,
    };

    pub const QuadInstance = extern struct {
        encoded_position: u32,
    };

    pub const QuadInstanceBuffer = gl.VertexBuffer(QuadInstance);

    const VertBufferBindings = struct {
        quad: gl.VertexBufferBind(QuadVert, .{}),
        quad_instances: gl.VertexBufferBind(QuadInstance, .{.divisor = 1}),
    };

    pub const VAO = gl.VertexArrayExt(VertBufferBindings, u32, VAOMixin);

    pub fn initVAO() VAO {
        var vao = VAO.init();
        const indices : [6]u32 = .{ 0, 1, 3, 0, 3, 2};
        const quad_verts : [4]QuadVert = .{ 
            .{ .id = 0 }, 
            .{ .id = 1 }, 
            .{ .id = 2 }, 
            .{ .id = 3 },
        };
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
    var x: u32 = 0;
    while (x < width) : (x += 1) {
        var y: u32 = 0;
        while (y < width) : (y += 1) {
            var z: u32 = 0;
            while (z < width) : (z += 1) {
                comptime var face: u32 = 0;
                const loc = autoVec(.{x, y, z}).intCast(Coords);
                inline while (face < 6) : (face += 1) {
                    const axis = face % 3;
                    const is_neg = face >= 3;
                    const sign = if (is_neg) -1 else 1;
                    const coord = loc.get(axis);
                    if (voxels.get(loc) > 0) {
                        const is_edge = if (is_neg) coord == 0 else coord == width - 1;
                        const neighbor_loc = loc.add(Coords.uniti(face));
                        const needs_face = is_edge or voxels.get(neighbor_loc) == 0;
                        if (needs_face) {
                            const instance: ChunkMesh.QuadInstance = .{
                                .encoded_position = x | y << 8 | z << 16 | face << 24,
                            };
                            try self.*.quad_instances.append(instance);
                        }
                    }
                }
            }
        }
    }
}