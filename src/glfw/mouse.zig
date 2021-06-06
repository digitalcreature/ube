usingnamespace @import("c");
const math = @import("math");
usingnamespace math.glm;
const Window = @import("window.zig").Window;

pub const Mouse = struct {

    window: Window.Handle,
    raw_input_supported: bool,
    last_cursor_position: Position = Position.zero,
    cursor_position_delta: Position = Position.zero,
    cursor_mode: CursorMode = .enabled,

    const Self = @This();

    pub const Position = DVec2;

    pub fn init(window: Window.Handle) Self {
        var self = .{
            .window = window,
            .raw_input_supported = glfwRawMouseMotionSupported() != GLFW_FALSE,
        };
        return self;
    }

    pub fn deinit(self: *Self) void {}

    pub fn update(self: *Self) void {
        var cursorPosition = self.getCursorPosition();
        self.cursor_position_delta = cursorPosition.sub(self.last_cursor_position);
        self.last_cursor_position = cursorPosition;
    }

    pub fn resetCursorPositionDelta(self: *Self) void {
        self.last_cursor_position = self.getCursorPosition();
        self.cursor_position_delta = Position.zero;
    } 

    pub fn getCursorPosition(self: *Self) Position {
        var x: f64 = undefined;
        var y: f64 = undefined;
        glfwGetCursorPos(self.window, &x, &y);
        return Position.init(x, y);
    }

    pub fn setCursorMode(self: *Self, mode: CursorMode) void {
        self.cursor_mode = mode;
        glfwSetInputMode(self.window, GLFW_CURSOR, @enumToInt(mode));
    }

    pub fn setRawInputMode(self: *Self, mode: RawInputMode) void {
        if (self.raw_input_supported) {
            const cursor_mode: CursorMode = switch (mode) {
                .enabled => .disabled,
                .disabled => .enabled,
            };
            self.setCursorMode(cursor_mode);
            glfwSetInputMode(self.window, GLFW_RAW_MOUSE_MOTION, @enumToInt(mode));
            glfwPollEvents();
            self.resetCursorPositionDelta();
        }
    }

    pub const RawInputMode = enum(c_int) {
        enabled = GLFW_TRUE,
        disabled = GLFW_FALSE,
    };

    pub const CursorMode = enum(c_int) {
        enabled = GLFW_CURSOR_NORMAL,
        // hidden = GLFW_CURSOR_HIDDEN,
        disabled = GLFW_CURSOR_DISABLED,
    };

};