const KeyCode = @import("glfw/keyboard.zig").KeyCode;

pub const Config = struct {
    voxel_size: f32 = 0.5,
    chunk_width: i32 = 24,

    win_width: c_int = 1920,
    win_height: c_int = 1080,

    action_close: KeyCode = .escape,
    action_cursor_mode: KeyCode = .grave,
    action_debughud: KeyCode = .f_3,
    action_fullscreen: KeyCode = .f_4,
    action_forward: KeyCode = .w,
    action_back: KeyCode = .s,
    action_left: KeyCode = .a,
    action_right: KeyCode = .d,
    action_up: KeyCode = .space,
    action_down: KeyCode = .left_shift,
};

pub const global_config: Config = .{};