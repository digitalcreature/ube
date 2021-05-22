const panic = @import("std").debug.panic;

usingnamespace @import("c");
usingnamespace @import("mouse.zig");
usingnamespace @import("keyboard.zig");
usingnamespace @import("time.zig");

const math = @import("math");

pub const FrameBufferSize = math.glm.IVec2;
pub const Window = struct {

    handle: Handle,
    mouse: Mouse,
    keyboard: Keyboard,
    time: FrameTimer,

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

        _ = glfwSetFramebufferSizeCallback(window, frameBufferSizeCallback);
        glfwPollEvents();

        return .{
            .handle = window,
            .mouse = Mouse.init(window),
            .keyboard = Keyboard.init(window),
            .time = FrameTimer.init(),
        };

    }

    pub fn deinit(self: *Self) void {}

    pub fn update(self: *Self) void {
        glfwPollEvents();
        self.mouse.update();
        self.keyboard.update();
        self.time.update();
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

    pub fn setVsyncMode(self: Self, mode: VsyncMode) void {
        glfwSwapInterval(@enumToInt(mode));
    }


    pub const VsyncMode = enum(c_int) {
        disabled = 0,
        enabled = 1,
    };

    pub fn getFrameBufferSize(self: Self) FrameBufferSize {
        var frame_buffer_size: FrameBufferSize = undefined;
        glfwGetFramebufferSize(self.handle, &frame_buffer_size.x, &frame_buffer_size.y);
        return frame_buffer_size;
    }

    fn frameBufferSizeCallback(window: ?Handle, width: c_int, height: c_int) callconv(.C) void {
        // make sure the viewport matches the new window dimensions; note that width and
        // height will be significantly larger than specified on retina displays.
        glViewport(0, 0, width, height);
    }


};