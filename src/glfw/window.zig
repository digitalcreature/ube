const panic = @import("std").debug.panic;

usingnamespace @import("c");
usingnamespace @import("mouse.zig");
usingnamespace @import("keyboard.zig");

pub const Window = struct {

    handle: Handle,
    mouse: Mouse,
    keyboard: Keyboard,

    pub const Handle = *GLFWwindow;

    const Self = @This();

    pub fn init(width: c_int, height: c_int, title: [:0]const u8) Self {
        // yeah its hardcoded eat my ass
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 5);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
        glfwWindowHint(GLFW_SAMPLES, 4);

        const window_opt: ?Handle = glfwCreateWindow(width, height, title, null, null);
        if (window_opt == null) {
            panic("Failed to create GLFW window\n", .{});
        }
        const window = window_opt.?;
        
        glfwMakeContextCurrent(window);
        glfwPollEvents();

        return .{
            .handle = window,
            .mouse = Mouse.init(window),
            .keyboard = Keyboard.init(window),
        };

    }

    pub fn deinit(self: *Self) void {}

    pub fn update(self: *Self) void {
        glfwPollEvents();
        self.mouse.update();
        self.keyboard.update();
    }

    pub fn shouldClose(self: Self) bool {
        return glfwWindowShouldClose(self.handle) != 0;
    }

    pub fn setShouldClose(self: Self, should_close: bool) void {
        glfwSetWindowShouldClose(self.handle, @boolToInt(should_close));
    }

    pub fn swapBuffers(self: Self) void {
        glfwSwapBuffers(self.handle);
    }

    pub fn setFrameBufferSizeCallback(self: Self, callback: FrameBufferSizeCallback) void {
        _ = glfwSetFramebufferSizeCallback(self.handle, callback);
    }

    pub const FrameBufferSizeCallback = fn(?Handle, c_int, c_int) callconv(.C) void;

};