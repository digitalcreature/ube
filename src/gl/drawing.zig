usingnamespace @import("c.zig");
const color = @import("math").color;

pub fn clearColor(col : color.ColorF32) void {
    glClearColor(col.r, col.g, col.b, col.a);
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


pub fn drawElementsOffset(primitive_type : PrimitiveType, count : c_int, comptime Index : type, offset : usize) void {
    const index_type = switch (Index) {
        u8 => GL_UNSIGNED_BYTE,
        u16 => GL_UNSIGNED_SHORT,
        u32 => GL_UNSIGNED_INT,
        else => @compileError("unsupported index buffer element type " ++ @typeName(Index)),
    };
    glDrawElements(@enumToInt(primitive_type), count, index_type, @intToPtr(?*c_void, offset));
}

pub fn drawElements(primitive_type : PrimitiveType, count : c_int, comptime Index : type) void {
    drawElementsOffset(primitive_type, count, Index, 0);
}