const panic = @import("std").debug.panic;

usingnamespace @import("c");
usingnamespace @import("mouse.zig");
usingnamespace @import("keyboard.zig");
usingnamespace @import("time.zig");

const math = @import("math");

pub const IVec2 = math.glm.IVec2;

pub const Window = struct {

    handle: Handle,
    mouse: Mouse,
    keyboard: Keyboard,
    time: FrameTimer,
    display_mode: DisplayMode,
    windowed_pos: IVec2,
    windowed_size: IVec2,

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

        var self = Self{
            .handle = window,
            .mouse = Mouse.init(window),
            .keyboard = Keyboard.init(window),
            .time = FrameTimer.init(),
            .display_mode = .windowed,
            .windowed_pos = IVec2.zero,
            .windowed_size = IVec2.zero,
        };
        self.saveWindowedShape();
        return self;

    }

    pub fn deinit(self: *Self) void {}
    
    fn saveWindowedShape(self: *Self) void {
        var pos: IVec2 = undefined;
        glfwGetWindowPos(self.handle, &pos.x, &pos.y);
        const size: IVec2 = self.getFrameBufferSize();
        self.windowed_pos = pos;
        self.windowed_size = size;
    }

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

    pub fn setDisplayMode(self: *Self, mode: DisplayMode, vsync_mode: VsyncMode) void {
        var monitor: *GLFWmonitor = glfwGetPrimaryMonitor().?;
        var vidmode: * const GLFWvidmode = glfwGetVideoMode(monitor);
        switch(mode) {
            // .windowed => {
            //     glfwRestoreWindow(self.handle);
            //     glfwSetWindowAttrib(self.handle, GLFW_FLOATING, GLFW_FALSE);
            //     glfwSetWindowAttrib(self.handle, GLFW_DECORATED, GLFW_TRUE);
            // },
            // .borderless => {
            //     glfwSetWindowAttrib(self.handle, GLFW_DECORATED, GLFW_FALSE);
            //     glfwMaximizeWindow(self.handle);
            //     glfwSetWindowAttrib(self.handle, GLFW_FLOATING, GLFW_TRUE);
            // },
            .windowed => {
                const pos = self.windowed_pos;
                const size = self.windowed_size;
                glfwSetWindowMonitor(self.handle, null, pos.x, pos.y, size.x, size.y, 0);
            },
            .borderless => {
                self.saveWindowedShape();
                glfwSetWindowMonitor(self.handle, monitor, 0, 0, vidmode.width, vidmode.height, vidmode.refreshRate);
            },
        }
        self.display_mode = mode;
        self.setVsyncMode(vsync_mode);
    }

    pub const DisplayMode = enum {
        windowed,
        borderless,
    };

    pub fn getFrameBufferSize(self: Self) IVec2 {
        var frame_buffer_size: IVec2 = undefined;
        glfwGetFramebufferSize(self.handle, &frame_buffer_size.x, &frame_buffer_size.y);
        return frame_buffer_size;
    }

    fn frameBufferSizeCallback(window: ?Handle, width: c_int, height: c_int) callconv(.C) void {
        // make sure the viewport matches the new window dimensions; note that width and
        // height will be significantly larger than specified on retina displays.
        glViewport(0, 0, width, height);
    }


};