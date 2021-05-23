usingnamespace @import("c");
usingnamespace @import("types.zig");

usingnamespace @import("texture_data.zig");

pub const TextureTarget = enum(u32) {
    tex_1d = GL_TEXTURE_1D,
    tex_2d = GL_TEXTURE_2D,
    tex_3d = GL_TEXTURE_3D,
    tex_1d_array = GL_TEXTURE_1D_ARRAY,
    tex_2d_array = GL_TEXTURE_2D_ARRAY,
    cube_map = GL_TEXTURE_CUBE_MAP,
    cube_map_array = GL_TEXTURE_CUBE_MAP_ARRAY,
    // rectangle = GL_TEXTURE_RECTANGLE,
    // buffer = GL_TEXTURE_BUFFER,
    // multisample_2d = GL_TEXTURE_2D_MULTISAMPLE,
    // multisample_2d_array = GL_TEXTURE_2D_MULTISAMPLE_ARRAY,
};

pub const TextureFilter = enum(i32) {
    nearest = GL_NEAREST,
    linear = GL_LINEAR,
};

pub const Texture2dRgb8 = Texture2d(PixelFormat.RGB_8);
pub const Texture2dRgba8 = Texture2d(PixelFormat.RGBA_8);

pub fn Texture2d(comptime pixel_format: PixelFormat) type {
    return Texture(.tex_2d, pixel_format);
}

pub fn Texture(comptime texture_target: TextureTarget, comptime pixel_format: PixelFormat) type {
    return struct {
        handle: Handle,

        pub const target = texture_target;

        const Self = @This();

        pub fn init() Self {
            var handle: Handle = undefined;
            glCreateTextures(@enumToInt(target), 1, &handle);
            return .{
                .handle = handle,
            };
        }

        pub fn deinit(self: Self) void {
            glDeleteTextures(1, &self.handle);
        }

        pub fn bindUnit(self: Self, unit: c_uint) void {
            glBindTextureUnit(unit, self.handle);
        }

        pub fn filter(self: Self, min_filter: TextureFilter, mag_filter: TextureFilter) void {
            glTextureParameteri(self.handle, GL_TEXTURE_MIN_FILTER, @enumToInt(min_filter));
            glTextureParameteri(self.handle, GL_TEXTURE_MAG_FILTER, @enumToInt(mag_filter));
        }

        pub usingnamespace switch (target) {
            .tex_2d, => struct {

                pub usingnamespace switch (pixel_format) {
                    .rgb, .rgba => |component| if (component == .byte) struct {

                        pub fn initPngBytes(comptime data: [] const u8) !Self {
                            var tex_data = try Texture2dData(pixel_format).initPngBytes(data);
                            return tex_data.createTextureAndDeinit();
                        }

                    }
                    else struct {},
                    else => struct {},
                };

                pub fn alloc(self: Self, data: Texture2dData(pixel_format)) void {
                    const width = @intCast(i32, data.width);
                    const height = @intCast(i32, data.height);
                    glTextureStorage2D(self.handle, 1, comptime pixel_format.sizedFormat(), width, height);
                }

                pub fn upload(self: Self, data: Texture2dData(pixel_format)) void {
                    const width = @intCast(i32, data.width);
                    const height = @intCast(i32, data.height);
                    const format_int = comptime pixel_format.toInt();
                    const pixel_type = @enumToInt(comptime pixel_format.getComponent());
                    const pixels = @ptrCast(*const c_void, data.pixels.ptr);
                    glTextureSubImage2D(self.handle, 0, 0, 0, width, height, format_int, pixel_type, pixels);
                }

                // pub fn storage(self: Self, levels: ?c_int, format: SizedTextureFormat, width: c_int, height: c_int) void {
                //     glTextureStorage2D(self.handle, levels orelse 1, @enumToInt(format), width, height);
                // }

                // pub fn subImage(self: Self, level: ?c_int, x: c_int, y: c_int, width: c_int, height: c_int, format: TextureFormat, comptime pixel_type: type, pixels: *const c_void) void {
                //     const pixel_type_enum = TexturePixelType.fromType(pixel_type);
                //     glTextureSubImage2D(self.handle, level orelse 0, x, y, width, height, @enumToInt(format), @enumToInt(pixel_type_enum), pixels);
                // }

            },
            else => struct {},
        };
    };
}