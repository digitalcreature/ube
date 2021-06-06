const imgui = @import("imgui");
const math = @import("math");
usingnamespace math.glm;
const glfw = @import("glfw");
const Camera = @import("camera").Camera;

pub const DebugHud = struct {
    
    is_visible: bool = false,
    window: *glfw.Window,
    camera: *Camera,
    frame_time_display: glfw.Time = 0.0,
    
    const Self = @This();

    pub fn init(window: *glfw.Window, camera: *Camera) Self {
        return .{ .window = window, .camera = camera};
    }

    pub fn draw(self: *Self) void {
        if (self.is_visible) {
            self.fpsOverlay();
        }
    }

    pub const fps_poll_rate: glfw.Time = 0.5;

    fn fpsOverlay(self : *Self) void {
        const time = &self.window.time;
        if (@divFloor(time.current_time, fps_poll_rate) != @divFloor(time.previous_time, fps_poll_rate)) {
            self.frame_time_display = time.frame_time;
        }
        const padding : f32 = 16;
        const window_pos = vec2(padding, padding);
        imgui.SetNextWindowPosExt(window_pos, .{ .Always = true }, Vec2.zero);
        const window_flags : imgui.WindowFlags = (imgui.WindowFlags {
            .NoMove = true,
            .NoBackground = true,
            .AlwaysAutoResize = true,
            .NoFocusOnAppearing = true,
        }).with(imgui.WindowFlags.NoDecoration).with(imgui.WindowFlags.NoNav);
        if (imgui.BeginExt("fps overlay", null, window_flags)) {
            defer imgui.End();
            const frame_time_display = self.frame_time_display;
            imgui.Text("frame time:\t%fms", frame_time_display * 1000);
            imgui.Text("fps:\t\t     %f", 1 / frame_time_display);
            imgui.NewLine();
            var mouse_pos = self.window.mouse.getCursorPosition();
            var mouse_delta = self.window.mouse.cursor_position_delta;
            imgui.Text("camera_xyz:\t\t   %i, %i, %i", @floatToInt(i32, self.camera.pos.x), @floatToInt(i32, self.camera.pos.y), @floatToInt(i32, self.camera.pos.z));
            imgui.Text("mouse_pos:\t\t    %f, %f", mouse_pos.x, mouse_pos.y);
            imgui.Text("mouse_delta:\t\t  %f, %f", mouse_delta.x, mouse_delta.y);
            imgui.Text("raw_input_supported: %i", @as(i32, @boolToInt(self.window.mouse.raw_input_supported)));
        }
    }
};
