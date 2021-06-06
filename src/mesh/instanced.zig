const std = @import("std");
const gl = @import("gl");
const math = @import("math");
usingnamespace math.glm;

fn fieldCount(comptime T: type) comptime_int {
    return @typeInfo(T).Struct.fields.len;
}

pub fn InstancedMesh(comptime VertexAttribs: type, comptime InstanceAttribs: type) type {

    return struct {

        pub const VertexBufferBindings = struct {
            verts: gl.VertexBufferBind(VertexAttribs, .{.bind_index = 0, .attrib_start = 0}),
            instances: gl.VertexBufferBind(InstanceAttribs, .{.bind_index = 1, .attrib_start = fieldCount(VertexAttribs), .divisor = 1}),
        };

        pub const Vao = gl.VertexArrayExt(VertBufferBindings, u32, VAOMixin);

        fn VAOMixin(comptime VAO: type) type {
            return struct {
                pub fn on_deinit(self: VAO) void {
                    self.deinitBoundIndexBuffer();
                    self.vertices.quad.deinitBoundBuffer();
                }
            };
        }

    };

}