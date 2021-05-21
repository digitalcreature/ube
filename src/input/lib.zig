usingnamespace @import("c");

pub usingnamespace @import("mouse.zig");

const Window = *GLFWwindow;

pub const Input = struct {

    window: Window,
    mouse: Mouse,

    const Self = @This();

    pub fn init(window: Window) Self {
        var self = Self{ .window = window, .mouse = Mouse.init(window) };
        return self;
    }

    pub fn deinit(self: *Self) void {}

    pub fn update(self: *Self) void {
        glfwPollEvents();
        self.mouse.update();
    }

};