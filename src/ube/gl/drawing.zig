usingnamespace @import("c.zig");
const color = @import("../math/color.zig");

pub fn clearColor(col : color.ColorF) void {
    glClearColor(col.x, col.y, col.z, col.w);
}

pub fn clearDepth(depth : anytype) void {
    switch (@TypeOf(depth)) {
        f32 => glClearDepthf(depth),
        f64 => glClearDepth(depth),
        else => |T| @compileError("depth values must be f32 or f64, not " ++ @typeName(T)),
    }
}

pub fn clearStencil(stencil : i32) void {
    glClearStencil(stencil);
}

pub const ClearFlags = enum(u32) {
    Color = GL_COLOR_BUFFER_BIT,
    Depth = GL_DEPTH_BUFFER_BIT,
    Stencil = GL_STENCIL_BUFFER_BIT,
    ColorDepth = GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT,
    DepthStencil = GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT,
    ColorStencil = GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT,
    ColorDepthStencil = GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT,
};

pub fn clear(flags : ClearFlags) void {
    glClear(@enumToInt(flags));
}