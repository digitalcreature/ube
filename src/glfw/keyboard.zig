const std = @import("std");
usingnamespace @import("c");
const math = @import("math");
usingnamespace math.glm;
const Window = @import("window.zig").Window;

pub const KeyState = enum(u1) {
    down = GLFW_PRESS,
    up = GLFW_RELEASE,

    pub fn fromCInt(i: c_int) KeyState {
        const u = @bitCast(c_uint, i) & 1;
        return @intToEnum(KeyState, @truncate(u1, u));
    }
};

pub const Keyboard = struct {

    window: Window.Handle,
    prev_state_index: usize,
    curr_state_index: usize,

    _states: [2]State,

    const Self = *@This();
    const SelfConst = * const @This();

    pub fn init(window: Window.Handle) Keyboard {
        var state: State = undefined;
        pollState(window, &state);
        return .{
            .window = window,
            .prev_state_index = 0,
            .curr_state_index = 1,
            ._states = .{ state, state },
        };
    }

    pub fn update(self: Self) void {
        const tmp = self.prev_state_index;
        self.prev_state_index = self.curr_state_index;
        self.curr_state_index = tmp;
        pollState(self.window, &(self._states[self.curr_state_index]));
    }

    pub fn didKeyChange(self: Self, comptime code: KeyCode, comptime state: KeyState) ?bool {
        const prev = self.previousKeyState(code);
        const curr = self.currentKeyState(code);
        return (prev != curr and curr == state);
    }

    pub fn wasKeyReleased(self: Self, comptime code: KeyCode) ?bool {
        return self.didKeyChange(code, .up);
    }

    pub fn wasKeyPressed(self: Self, comptime code: KeyCode) ?bool {
        return self.didKeyChange(code, .down);
    }

    pub fn isKey(self: Self, comptime code: KeyCode, comptime state: KeyState) ?bool {
        return self.currentKeyState(code) == state;
    }

    pub fn isKeyDown(self: Self, comptime code: KeyCode) ?bool {
        return self.isKey(code, .down);
    }

    pub fn isKeyUp(self: Self, comptime code: KeyCode) ?bool {
        return self.isKey(code, .up);
    }

    fn getKeyState(self: Self, comptime code: KeyCode, index: usize) KeyState {
        return self._states[index].get(code);
    }

    pub fn previousKeyState(self: Self, comptime code: KeyCode) KeyState {
        return self.getKeyState(code, self.prev_state_index);
    }

    pub fn currentKeyState(self: Self, comptime code: KeyCode) KeyState {
        return self.getKeyState(code, self.curr_state_index);
    }

    pub fn currState(self: Self) *State {
        return &self._states[self.curr_state_index];
    }

    pub fn prevState(self: Self) *State {
        return &self._states[self.prev_state_index];
    }

    fn pollState(window: Window.Handle, state: *State) void {
        comptime var i: usize = 0;
        inline while (i < KeyCode.count) : (i += 1) {
            const key_state = glfwGetKey(window, KeyCode.fields[i].value);
            state.keys[i] = KeyState.fromCInt(key_state);
        }
    }

    pub const State = struct {

        keys: StateArray = std.mem.zeroes(StateArray),

        pub fn get(self: State, comptime code: KeyCode) KeyState {
            return self.keys[comptime code.index()];
        }

        pub const StateArray = [KeyCode.count]KeyState;

    };

};


pub const KeyCode = enum(c_int) {

    pub const fields = @typeInfo(KeyCode).Enum.fields;

    pub const count = fields.len - 1; // subtract one for .unkown

    // yeah this is suboptimal, but i dont know how to do some sort of "inline switch"
    // this is only to be used at runtime, as there isnt really a better option i can think of.
    // TODO: improve keycode indexing with runtime keycodes, it could cause issues with rebindable controls
    pub fn index(comptime code: KeyCode) usize {
        if (code == .unknown) {
            @compileError("cannot index with KeyCode.unknown");
        }
        comptime var i: usize = 0;
        comptime var match: ?usize = null;
        inline while (i < count) : (i += 1) {
            if (match == null and @as(c_int, fields[i].value) == @enumToInt(code)) {
                match = i;
            }
        }
        return match.?;
    }

    space = GLFW_KEY_SPACE,
    apostrophe = GLFW_KEY_APOSTROPHE,
    comma = GLFW_KEY_COMMA,
    minus = GLFW_KEY_MINUS,
    period = GLFW_KEY_PERIOD,
    slash = GLFW_KEY_SLASH,
    alpha_0 = GLFW_KEY_0,
    alpha_1 = GLFW_KEY_1,
    alpha_2 = GLFW_KEY_2,
    alpha_3 = GLFW_KEY_3,
    alpha_4 = GLFW_KEY_4,
    alpha_5 = GLFW_KEY_5,
    alpha_6 = GLFW_KEY_6,
    alpha_7 = GLFW_KEY_7,
    alpha_8 = GLFW_KEY_8,
    alpha_9 = GLFW_KEY_9,
    semicolon = GLFW_KEY_SEMICOLON,
    equal = GLFW_KEY_EQUAL,
    a = GLFW_KEY_A,
    b = GLFW_KEY_B,
    c = GLFW_KEY_C,
    d = GLFW_KEY_D,
    e = GLFW_KEY_E,
    f = GLFW_KEY_F,
    g = GLFW_KEY_G,
    h = GLFW_KEY_H,
    i = GLFW_KEY_I,
    j = GLFW_KEY_J,
    k = GLFW_KEY_K,
    l = GLFW_KEY_L,
    m = GLFW_KEY_M,
    n = GLFW_KEY_N,
    o = GLFW_KEY_O,
    p = GLFW_KEY_P,
    q = GLFW_KEY_Q,
    r = GLFW_KEY_R,
    s = GLFW_KEY_S,
    t = GLFW_KEY_T,
    u = GLFW_KEY_U,
    v = GLFW_KEY_V,
    w = GLFW_KEY_W,
    x = GLFW_KEY_X,
    y = GLFW_KEY_Y,
    z = GLFW_KEY_Z,
    left_bracket = GLFW_KEY_LEFT_BRACKET,
    backslash = GLFW_KEY_BACKSLASH,
    right_bracket = GLFW_KEY_RIGHT_BRACKET,
    grave = GLFW_KEY_GRAVE_ACCENT,
    world_1 = GLFW_KEY_WORLD_1,
    world_2 = GLFW_KEY_WORLD_2,
    escape = GLFW_KEY_ESCAPE,
    enter = GLFW_KEY_ENTER,
    tab = GLFW_KEY_TAB,
    backspace = GLFW_KEY_BACKSPACE,
    insert = GLFW_KEY_INSERT,
    delete = GLFW_KEY_DELETE,
    right = GLFW_KEY_RIGHT,
    left = GLFW_KEY_LEFT,
    down = GLFW_KEY_DOWN,
    up = GLFW_KEY_UP,
    page_up = GLFW_KEY_PAGE_UP,
    page_down = GLFW_KEY_PAGE_DOWN,
    home = GLFW_KEY_HOME,
    end = GLFW_KEY_END,
    caps_lock = GLFW_KEY_CAPS_LOCK,
    scroll_lock = GLFW_KEY_SCROLL_LOCK,
    num_lock = GLFW_KEY_NUM_LOCK,
    print_screen = GLFW_KEY_PRINT_SCREEN,
    pause = GLFW_KEY_PAUSE,
    f_1 = GLFW_KEY_F1,
    f_2 = GLFW_KEY_F2,
    f_3 = GLFW_KEY_F3,
    f_4 = GLFW_KEY_F4,
    f_5 = GLFW_KEY_F5,
    f_6 = GLFW_KEY_F6,
    f_7 = GLFW_KEY_F7,
    f_8 = GLFW_KEY_F8,
    f_9 = GLFW_KEY_F9,
    f_10 = GLFW_KEY_F10,
    f_11 = GLFW_KEY_F11,
    f_12 = GLFW_KEY_F12,
    f_13 = GLFW_KEY_F13,
    f_14 = GLFW_KEY_F14,
    f_15 = GLFW_KEY_F15,
    f_16 = GLFW_KEY_F16,
    f_17 = GLFW_KEY_F17,
    f_18 = GLFW_KEY_F18,
    f_19 = GLFW_KEY_F19,
    f_20 = GLFW_KEY_F20,
    f_21 = GLFW_KEY_F21,
    f_22 = GLFW_KEY_F22,
    f_23 = GLFW_KEY_F23,
    f_24 = GLFW_KEY_F24,
    f_25 = GLFW_KEY_F25,
    kp_0 = GLFW_KEY_KP_0,
    kp_1 = GLFW_KEY_KP_1,
    kp_2 = GLFW_KEY_KP_2,
    kp_3 = GLFW_KEY_KP_3,
    kp_4 = GLFW_KEY_KP_4,
    kp_5 = GLFW_KEY_KP_5,
    kp_6 = GLFW_KEY_KP_6,
    kp_7 = GLFW_KEY_KP_7,
    kp_8 = GLFW_KEY_KP_8,
    kp_9 = GLFW_KEY_KP_9,
    kp_decimal = GLFW_KEY_KP_DECIMAL,
    kp_divide = GLFW_KEY_KP_DIVIDE,
    kp_multiply = GLFW_KEY_KP_MULTIPLY,
    kp_subtract = GLFW_KEY_KP_SUBTRACT,
    kp_add = GLFW_KEY_KP_ADD,
    kp_enter = GLFW_KEY_KP_ENTER,
    kp_equal = GLFW_KEY_KP_EQUAL,
    left_shift = GLFW_KEY_LEFT_SHIFT,
    left_control = GLFW_KEY_LEFT_CONTROL,
    left_alt = GLFW_KEY_LEFT_ALT,
    left_super = GLFW_KEY_LEFT_SUPER,
    right_shift = GLFW_KEY_RIGHT_SHIFT,
    right_control = GLFW_KEY_RIGHT_CONTROL,
    right_alt = GLFW_KEY_RIGHT_ALT,
    right_super = GLFW_KEY_RIGHT_SUPER,
    menu = GLFW_KEY_MENU,
    unknown = GLFW_KEY_UNKNOWN,
};