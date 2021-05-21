const imgui = @import("imgui");
const math = @import("math");
usingnamespace math.glm;
const glfw = @import("glfw");

pub const DebugHud = struct {
    
    is_visible: bool = false,
    frame_time: f64 = 0,
    window: *glfw.Window,
    
    const Self = @This();

    pub fn init(window: *glfw.Window) Self {
        return .{ .window = window};
    }

    pub fn draw(self: *Self) void {
        if (self.is_visible) {
            self.fpsOverlay();
        }
    }

    fn fpsOverlay(self : Self) void {
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
            imgui.Text("frame time:\t%fms", self.frame_time * 1000);
            imgui.Text("fps:\t\t  %f", 1 / self.frame_time);
            imgui.NewLine();
            var mouse_pos = self.window.mouse.getCursorPosition();
            var mouse_delta = self.window.mouse.cursor_position_delta;
            imgui.Text("mouse_pos:\t\t  %f, %f", mouse_pos.x, mouse_pos.y);
            imgui.Text("mouse_delta:\t\t  %f, %f", mouse_delta.x, mouse_delta.y);
            imgui.Text("raw_input_supported: %i", @as(i32, @boolToInt(self.window.mouse.raw_input_supported)));
        }
    }
};
