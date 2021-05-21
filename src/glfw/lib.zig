const panic = @import("std").debug.panic;

usingnamespace @import("c");
pub usingnamespace @import("window.zig");

pub fn init() void {
    if (glfwInit() == 0) {
        panic("Failed to initialise GLFW\n", .{});
    }
}

pub fn deinit() void {
    glfwTerminate();
}