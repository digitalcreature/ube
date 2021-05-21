const std = @import("std");
usingnamespace @import("c");
// const math = @import("math");
// usingnamespace math.glm;
// const Window = @import("window.zig").Window;

pub const Time = f64;

pub const FrameTimer = struct {
    
    previous_time: Time,
    current_time: Time,
    frame_time: Time,

    const Self = *@This();

    pub fn init() FrameTimer {
        const time = getTime();
        return .{
            .previous_time = time,
            .current_time = time,
            .frame_time = 0,
        };
    }

    pub fn update(self: Self) void {
        self.previous_time = self.current_time;
        self.current_time = getTime();
        self.frame_time = self.current_time - self.previous_time;
    }

    pub fn getTime() Time {
        return glfwGetTime();
    }

};