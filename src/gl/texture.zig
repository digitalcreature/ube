usingnamespace @import("c");
usingnamespace @import("types.zig");

usingnamespace @import("texture_data.zig");

pub const TextureTarget = enum(u32) {
    // tex_1d = GL_TEXTURE_1D,
    single_2d = GL_TEXTURE_2D,
    // tex_3d = GL_TEXTURE_3D,
    // tex_1d_array = GL_TEXTURE_1D_ARRAY,
    array_2d = GL_TEXTURE_2D_ARRAY,
    // cube_map = GL_TEXTURE_CUBE_MAP,
    // cube_map_array = GL_TEXTURE_CUBE_MAP_ARRAY,
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

pub const Texture2dArrayRgb8 = Texture2dArray(PixelFormat.RGB_8);
pub const Texture2dArrayRgba8 = Texture2dArray(PixelFormat.RGBA_8);

pub fn Texture2d(comptime pixel_format: PixelFormat) type {
    return Texture(.single_2d, pixel_format);
}

pub fn Texture2dArray(comptime pixel_format: PixelFormat) type {
    return Texture(.array_2d, pixel_format);
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

        pub fn filterMip(self: Self, min_filter: TextureFilter, mag_filter: TextureFilter, mip_filter: TextureFilter) void {
            const min_mip_filter: i32 = switch(min_filter) {
                .nearest => switch(mip_filter) {
                    .nearest => @as(i32, GL_NEAREST_MIPMAP_NEAREST),
                    .linear => @as(i32, GL_NEAREST_MIPMAP_LINEAR),
                },
                .linear => switch(mip_filter) {
                    .nearest => @as(i32, GL_LINEAR_MIPMAP_NEAREST),
                    .linear => @as(i32, GL_LINEAR_MIPMAP_LINEAR),
                },
            };
            glTextureParameteri(self.handle, GL_TEXTURE_MIN_FILTER, min_mip_filter);
            glTextureParameteri(self.handle, GL_TEXTURE_MAG_FILTER, @enumToInt(mag_filter));
        }

        pub fn generateMipMaps(self: Self) void {
            glGenerateTextureMipmap(self.handle);
        }

        pub usingnamespace switch (target) {
            .single_2d, => struct {

                pub usingnamespace switch (pixel_format) {
                    .rgb, .rgba => |component| if (component == .byte) struct {

                        pub fn initPngBytes(comptime data: [] const u8, mip_map_levels: ?usize) !Self {
                            var tex_data = try TextureData2d(pixel_format).initPngBytes(data);

                            return tex_data.createTextureAndDeinit(mip_map_levels);
                        }

                    }
                    else struct {},
                    else => struct {},
                };

                pub fn alloc(self: Self, width: usize, height: usize, mip_map_levels: ?usize) void {
                    const w = @intCast(i32, width);
                    const h = @intCast(i32, height);
                    glTextureStorage2D(self.handle, @intCast(i32, mip_map_levels orelse 1), comptime pixel_format.sizedFormat(), w, h);
                }

                pub fn allocForData(self: Self, data: TextureData2d(pixel_format), mip_map_levels: ?usize) void {
                    self.alloc(data.width, data.height, mip_map_levels);
                }

                pub fn uploadData(self: Self, data: TextureData2d(pixel_format), mip_map_level: ?usize) void {
                    const width = @intCast(i32, data.width);
                    const height = @intCast(i32, data.height);
                    const format_int = comptime pixel_format.toInt();
                    const pixel_type = @enumToInt(comptime pixel_format.getComponent());
                    const pixels = @ptrCast(*const c_void, data.pixels.ptr);
                    glTextureSubImage2D(self.handle, @intCast(i32, mip_map_level orelse 0), 0, 0, width, height, format_int, pixel_type, pixels);
                }

            },
            .array_2d => struct {

                pub fn alloc(self: Self, width: usize, height: usize, count: usize, mip_map_levels: ?usize) void {
                    const w = @intCast(i32, width);
                    const h = @intCast(i32, height);
                    const c = @intCast(i32, count);
                    const mips = @intCast(i32, mip_map_levels orelse 1);
                    glTextureStorage3D(self.handle, mips, comptime pixel_format.sizedFormat(), w, h, c);
                }

                pub fn uploadData2d(self: Self, data: TextureData2d(pixel_format), index: usize, mip_map_level: ?usize) void {
                    const w = @intCast(i32, data.width);
                    const h = @intCast(i32, data.height);
                    const i = @intCast(i32, index);
                    const mip = @intCast(i32, mip_map_level orelse 0);
                    const format = comptime pixel_format.toInt();
                    const pixel_type = @enumToInt(comptime pixel_format.getComponent());
                    const pixels = @ptrCast(*const c_void, data.pixels.ptr);
                    glTextureSubImage3D(self.handle, mip, 0, 0, i, w, h, 1, format, pixel_type, pixels);
                }

            },
            // else => struct {},
        };
    };
}