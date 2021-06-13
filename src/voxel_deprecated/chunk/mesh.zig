const std = @import("std");
const math = @import("math");
const gl = @import("gl");

usingnamespace math.glm;
usingnamespace @import("../types.zig");
usingnamespace @import("../chunk.zig");

const Allocator = std.mem.Allocator;
const Cardinal = Coords.Cardinal;

pub fn Mesher(comptime InstanceType: type) type {
    return struct {

        allocator: *Allocator,
        generateInstancesFromVoxel: GenerateInstancesFromVoxelFn,
        instances: InstanceList,

        pub const Instance = InstanceType;
        pub const InstanceBuffer = gl.VertexBuffer(Instance);
        pub const InstanceList = std.ArrayList(Instance);
        
        pub const GenerateInstancesFromVoxelFn = fn(*Self, Voxel, *const Chunk, usize) anyerror!void;

        const Self = @This();

        pub fn init(Allocator: *Allocator, generateInstancesFromVoxel: GenerateInstancesFromVoxelFn) Self {
            return Self{
                .allocator = Allocator,
                .generateInstancesFromVoxel = generateInstancesFromVoxel,
                .instances = InstanceList.init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.instances.deinit();
        }

        pub fn generateInstancesFromChunk(self: *Self, chunk: *const Chunk) !void {
            for (chunk.voxels.data) |voxel, i| {
                try self.generateInstancesFromVoxel(self, voxel, chunk, i);
            }
        }

        pub fn uploadInstancesToBuffer(self: Self, buffer: InstanceBuffer) void {
            buffer.data(self.instances.items, .StaticDraw);
        }

        pub fn toMesh(self: Self) Mesh(Instance) {
            const mesh = Mesh(Instance).init();
            self.uploadInstancesToBuffer(mesh.buffer);
        }

    };
}

pub fn Mesh(comptime InstanceType: type) type {

    return struct {

        instance_buffer: InstanceBuffer = null,

        pub const Instance = InstanceType;
        pub const InstanceBuffer = gl.VertexBuffer(Instance);

        const Self = @This();

        pub fn init() Self {
            return Self{
                .instance_buffer = InstanceBuffer.init(),
            };
        }

        pub fn deinit(self: *Self) void {
            self.instance_buffer.deinit();
        }

    };

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
// const QuadVertId = enum(u2) {
//     np = 0,
//     pp = 1,
//     nn = 2,
//     pn = 3,
// };