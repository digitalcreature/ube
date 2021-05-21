const panic = @import("std").debug.panic;

usingnamespace @import("c");
pub usingnamespace @import("window.zig");
pub usingnamespace @import("mouse.zig");
pub usingnamespace @import("keyboard.zig");
pub usingnamespace @import("time.zig");

pub fn init() void {
    if (glfwInit() == 0) {
        panic("Failed to initialise GLFW\n", .{});
    }
}

pub fn deinit() void {
    glfwTerminate();
}