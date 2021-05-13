usingnamespace @import("c.zig");
usingnamespace @import("types.zig");

pub const TextureTarget = enum(u32) {
    D1 = GL_TEXTURE_1D,
    D2 = GL_TEXTURE_2D,
    D3 = GL_TEXTURE_3D,
    D1Array = GL_TEXTURE_1D_ARRAY,
    D2Array = GL_TEXTURE_2D_ARRAY,
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

pub const TextureFormat = enum(u32) {};

pub fn Texture(comptime target: TextureTarget) type {
    return struct {
        handle: Handle,

        pub const target = target;

        const Self = @This();

        pub fn init() Self {
            var handle: Handle = undefined;
            glCreateTextures(target, 1, &handle);
            return .{
                .handle = handle,
            };
        }

        pub fn deinit(self: Self) void {
            glDeleteTextures(1, &self.handle);
        }

        pub usingnamespace switch (target) {
            .D2, .D1Array => struct {
                // pub fn storage(self : Self, width : usize, height : usize, levels : usize, )
            },
        };
    };
}
