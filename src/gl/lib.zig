pub usingnamespace @import("buffer.zig");
pub usingnamespace @import("drawing.zig");
pub usingnamespace @import("shader.zig");
pub usingnamespace @import("types.zig");
pub usingnamespace @import("vertexarray.zig");
pub usingnamespace @import("uniform.zig");
pub usingnamespace @import("texture.zig");

usingnamespace @import("c");

pub fn init() void {
    if (gladLoadGLLoader(@ptrCast(GLADloadproc, glfwGetProcAddress)) == 0) {
        @panic("Failed to initialise GLAD");
    }
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_MULTISAMPLE);
    glEnable(GL_CULL_FACE);
}

pub fn viewport(x: c_int, y: c_int, width: c_int, height: c_int) void{
    glViewport(x, y, width, height);
}