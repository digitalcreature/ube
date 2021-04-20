usingnamespace @import("c.zig");
const color = @import("../math/color.zig");

pub const PrimitiveType = enum(c_uint) {
    Points = GL_POINTS,
    LineStrip = GL_LINE_STRIP,
    LineLoop = GL_LINE_LOOP,
    Lines = GL_LINES,
    LineStripAdjacency = GL_LINE_STRIP_ADJACENCY,
    LinesAdjacency = GL_LINES_ADJACENCY,
    TriangleStrip = GL_TRIANGLE_STRIP,
    TriangleFan = GL_TRIANGLE_FAN,
    Triangles = GL_TRIANGLES,
    TriangleStripAdjacency = GL_TRIANGLE_STRIP_ADJACENCY,
    TrianglesAdjacency = GL_TRIANGLES_ADJACENCY,
    // Patches = GL_PATCHES,
};

pub fn draw_elements(mode : PrimitiveType, count : i32, comptime Index : type, offset : u32) void {
    const index_type = switch(Index) {
        u8 => GL_UNSIGNED_BYTE,
        u16 => GL_UNSIGNED_SHORT,
        u32 => GL_UNSIGNED_INT,
        else => unreachable,
    };
    glDrawElements(@enumToInt(mode), count, index_type, @intToPtr(?*c_void, offset));
}

pub fn clear_color(col : color.ColorF) void {
    glClearColor(col.x, col.y, col.z, col.w);
}

pub fn clear_depth(depth : anytype) void {
    switch (@TypeOf(depth)) {
        f32 => glClearDepthf(depth),
        f64 => glClearDepth(depth),
        else => |T| @compileError("depth values must be f32 or f64, not " ++ @typeName(T)),
    }
}

pub fn clear_stencil(stencil : i32) void {
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