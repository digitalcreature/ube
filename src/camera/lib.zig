const math = @import("math");
const glfw = @import("glfw");
const std = @import("std");
usingnamespace math.glm;

const global_config = @import("../config.zig").global_config;

pub const Camera = struct {

    proj: Mat4 = Mat4.identity,
    view: Mat4 = Mat4.identity,
    pos: Vec3 = Vec3.zero,
    move_speed: f32 = 25,
    look_angles: DVec2 = DVec2.zero,

    const Self = @This();

    pub fn init() Self {
        return .{};
    }

    pub fn update(self: *Self, window: *glfw.Window) void {
        if (window.mouse.cursor_mode == .disabled) {
            var mouse_delta = window.mouse.cursor_position_delta.scale(window.time.frame_time * 10);
            var look_angles = self.look_angles.add(mouse_delta);
            if (look_angles.y > 90) {
                look_angles.y = 90;
            }
            if (look_angles.y < -90) {
                look_angles.y = -90;
            }
            self.look_angles = look_angles;
            const look_angles_radians = look_angles.scale(std.math.pi / 180.0).floatCast(Vec2);
            const view = Mat4.createEulerZXY(-look_angles_radians.y, -look_angles_radians.x, 0);
            var pos = self.pos;
            const forward = view.transformDirection(Vec3.unit("z"));
            const right = view.transformDirection(Vec3.unit("x"));
            if (window.keyboard.isKeyDown(global_config.action_forward).?) {
                pos = pos.add(forward.scale(self.move_speed * @floatCast(f32, window.time.frame_time)));
            }
            if (window.keyboard.isKeyDown(global_config.action_back).?) {
                pos = pos.add(forward.scale(-self.move_speed * @floatCast(f32, window.time.frame_time)));
            }
            if (window.keyboard.isKeyDown(global_config.action_left).?) {
                pos = pos.add(right.scale(-self.move_speed * @floatCast(f32, window.time.frame_time)));
            }
            if (window.keyboard.isKeyDown(global_config.action_right).?) {
                pos = pos.add(right.scale(self.move_speed * @floatCast(f32, window.time.frame_time)));
            }
            if (window.keyboard.isKeyDown(global_config.action_up).?) {
                pos = pos.add(Vec3.unit("y").scale(self.move_speed * @floatCast(f32, window.time.frame_time)));
            }
            if (window.keyboard.isKeyDown(global_config.action_down).?) {
                pos = pos.add(Vec3.unit("y").scale(-self.move_speed * @floatCast(f32, window.time.frame_time)));
            }
            self.pos = pos;
            self.view = (Mat4.createTranslation(pos).invert() orelse Mat4.identity).mul(view);
        }
        const frame_buffer_size = window.getFrameBufferSize();
        const aspect: f32 = @intToFloat(f32, frame_buffer_size.x) / @intToFloat(f32, frame_buffer_size.y);
        self.proj = Mat4.createPerspective(1.5708, aspect, 0.1, 1000);
    }


};