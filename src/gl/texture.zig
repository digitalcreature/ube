usingnamespace @import("c");
usingnamespace @import("types.zig");

pub const TextureTarget = enum(u32) {
    Tex1D = GL_TEXTURE_1D,
    Tex2D = GL_TEXTURE_2D,
    Tex3D = GL_TEXTURE_3D,
    Tex1DArray = GL_TEXTURE_1D_ARRAY,
    Tex2DArray = GL_TEXTURE_2D_ARRAY,
    Rectangle = GL_TEXTURE_RECTANGLE,
    CubeMap = GL_TEXTURE_CUBE_MAP,
    CubeMapArray = GL_TEXTURE_CUBE_MAP_ARRAY,
    Buffer = GL_TEXTURE_BUFFER,
    D2Multisample = GL_TEXTURE_2D_MULTISAMPLE,
    D2MultisampleArray = GL_TEXTURE_2D_MULTISAMPLE_ARRAY,
    // CubeMapPosX = GL_CUBE_MAP_POSITIVE_X,
    // CubeMapPosY = GL_CUBE_MAP_POSITIVE_Y,
    // CubeMapPosZ = GL_CUBE_MAP_POSITIVE_Z,
    // CubeMapNegX = GL_CUBE_MAP_NEGATIVE_X,
    // CubeMapNegY = GL_CUBE_MAP_NEGATIVE_Y,
    // CubeMapNegZ = GL_CUBE_MAP_NEGATIVE_Z,
};

pub const SizedTextureFormat = enum(u32) {
    RGBA8 = GL_RGBA8,
    RGB8 = GL_RGB8,
};

pub const TextureFormat = enum(u32) {
    r = GL_RED,
    rg = GL_RG,
    rgb = GL_RGB,
    rgba = GL_RGBA,
};

pub const TexturePixelType = enum(u32) {
    unsigned_byte = GL_UNSIGNED_BYTE,

    pub fn fromType(comptime T: type) @This() {
        return switch (T) {
            u8 => .unsigned_byte,
            else => @compileError("invalid texture pixel format type " ++ @typeName(T)),
        };
    }
};

pub const Texture2D = Texture(.Tex2D);

pub fn Texture(comptime texture_target: TextureTarget) type {
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

        pub usingnamespace switch (target) {
            .Tex2D, .Tex1DArray => struct {
                pub fn storage(self: Self, levels: ?c_int, format: SizedTextureFormat, width: c_int, height: c_int) void {
                    glTextureStorage2D(self.handle, levels orelse 1, @enumToInt(format), width, height);
                }

                pub fn subImage(self: Self, level: ?c_int, x: c_int, y: c_int, width: c_int, height: c_int, format: TextureFormat, comptime pixel_type: type, data: anytype) void {
                    const pixel_type_enum = TexturePixelType.fromType(pixel_type);
                    glTextureSubImage2D(self.handle, level orelse 0, x, y, width, height, @enumToInt(format), @enumToInt(pixel_type_enum), data);
                }
            },
            else => struct {},
        };
    };
}


pub const AlphaChannelFlag = enum {
    has_alpha,
    no_alpha,
};

pub fn loadTextureFromPngBytes(comptime bytes: []const u8, comptime alpha_flag: AlphaChannelFlag) Texture2D {
    var width: i32 = undefined;
    var height: i32 = undefined;
    var channels: i32 = undefined;
    var pixels: *u8 = stbi_load_from_memory(bytes.ptr, bytes.len, &width, &height, &channels, 0);
    defer stbi_image_free(pixels);
    var tex = Texture2D.init();
    const sized_format: SizedTextureFormat = if (alpha_flag == .has_alpha) .RGBA8 else .RGB8;
    const format: TextureFormat = if (alpha_flag == .has_alpha) .rgba else .rgb;
    tex.storage(null, sized_format, width, height);
    tex.subImage(null, 0, 0, width, height, format, u8, pixels);
    glTextureParameteri(tex.handle, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTextureParameteri(tex.handle, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    return tex;
}