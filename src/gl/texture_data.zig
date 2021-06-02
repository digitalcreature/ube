const std = @import("std");

usingnamespace @import("c");
usingnamespace @import("types.zig");
usingnamespace @import("texture.zig");
const math = @import("math");
usingnamespace math.glm;

const Allocator = std.mem.Allocator;

pub const TextureData2dRgb8 = TextureData2d(PixelFormat.RGB_8);
pub const TextureData2dRgba8 = TextureData2d(PixelFormat.RGBA_8);

pub fn TextureData2d(comptime format: PixelFormat) type {    
    
    return struct {

        allocator: *Allocator,

        width: usize,
        height: usize,
        pixels: []Pixel,

        pub const Pixel = format.Type();

        const Self = @This();

        // pub fn initBlank(allocator: *Allocator, width: usize, height: usize) Self {
        //     return .{
        //         .allocator = allocator,
        //         .width = width,
        //         .height = height,
        //         .pixels = allocator.alloc(Pixel, width * height),
        //     };
        // }


        pub usingnamespace switch (format) {
            .rgb, .rgba => |component| switch (component) {
                .byte => struct {

                    pub fn initPngBytes(comptime bytes: [] const u8) !Self {
                        var width: i32 = undefined;
                        var height: i32 = undefined;
                        var channels: i32 = undefined;
                        var pixels_bytes: [*c]u8 = stbi_load_from_memory(bytes.ptr, bytes.len, &width, &height, &channels, 0);
                        var pixels_opt = @ptrCast(?[*]Pixel, pixels_bytes);
                        if (pixels_opt) |pixels| {
                            errdefer stbi_image_free(pixels);
                            if (channels != format.channels()) {
                                return error.incorrect_channel_count;
                            }
                            else {
                                const w = @intCast(usize, width);
                                const h = @intCast(usize, height);
                                return Self{
                                    // NOTE: swap this for std.heap.raw_c_allocator after 0.8
                                    .allocator = std.heap.c_allocator, // stbi just calls free() to deallocate
                                    .width = w,
                                    .height = h,
                                    .pixels = pixels[0..(w * h)],
                                };
                            }
                        }
                        else {
                            return error.stbi_allocation_failure;
                        }
                    }

                },
                else => struct {},
            },
            else => struct {},
        };

        pub fn createTexture(self: Self, mip_map_levels: ?usize) Texture2d(format) {
            const texture = Texture2d(format).init();
            texture.allocForData(self, mip_map_levels);
            texture.uploadData(self, null);
            return texture;
        }

        pub fn createTextureAndDeinit(self: *Self, mip_map_levels: ?usize) Texture2d(format) {
            const tex = self.createTexture(mip_map_levels);
            self.deinit();
            return tex;
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.pixels);
        }


    };

}

pub const PixelFormat = union(enum) {

    r: PixelComponent,
    rg: PixelComponent,
    rgb: PixelComponent,
    rgba: PixelComponent,

    pub const RGB_8 = PixelFormat.init(.rgb, .byte);
    pub const RGBA_8 = PixelFormat.init(.rgba, .byte);


    pub const Tag = std.meta.TagType(PixelFormat);

    pub fn toInt(self: PixelFormat) u32 {
        return switch (self) {
            .r => GL_RED,
            .rg => GL_RG,
            .rgb => GL_RGB,
            .rgba => GL_RGBA,
        };
    }

    pub fn init(format: Tag, component: PixelComponent) PixelFormat {
        return switch (format) {
            .r => .{ .r = component },
            .rg => .{ .rg = component },
            .rgb => .{ .rgb = component },
            .rgba => .{ .rgba = component },
        };
    }

    pub fn channels(self: PixelFormat) u8 {
        return switch (self) {
            .r => 1,
            .rg => 2,
            .rgb => 3,
            .rgba => 4,
        };
    }

    pub fn getComponent(self: PixelFormat) PixelComponent {
        return switch (self) {
            .r => |component| component,
            .rg => |component| component,
            .rgb => |component| component,
            .rgba => |component| component,
        };
    }

    pub fn sizedFormat(self: PixelFormat) u32 {
        return switch (self) {
            .r => |component| switch(component) {
                .byte => @as(u32, GL_R8),
                .signed_byte => @as(u32, GL_R8_SNORM),
                .short => @as(u32, GL_R16),
                .signed_short => @as(u32, GL_R16_SNORM),
                .float => @as(u32, GL_R32F),
            },
            .rg => |component| switch(component) {
                .byte => @as(u32, GL_RG8),
                .signed_byte => @as(u32, GL_RG8_SNORM),
                .short => @as(u32, GL_RG16),
                .signed_short => @as(u32, GL_RG16_SNORM),
                .float => @as(u32, GL_RG32F),
            },
            .rgb => |component| switch(component) {
                .byte => @as(u32, GL_RGB8),
                .signed_byte => @as(u32, GL_RGB8_SNORM),
                // .short => @as(u32, GL_RGB16),
                .short => @panic("no 16 bit unsigned rgb format! open gl is weird, idk what to tell you"),
                .signed_short => @as(u32, GL_RGB16_SNORM),
                .float => @as(u32, GL_RGB32F),
            },
            .rgba => |component| switch(component) {
                .byte => @as(u32, GL_RGBA8),
                .signed_byte => @as(u32, GL_RGBA8_SNORM),
                .short => @as(u32, GL_RGBA16),
                .signed_short => @as(u32, GL_RGBA16_SNORM),
                .float => @as(u32, GL_RGBA32F),
            },
        };
    }


    pub fn Type(comptime format: PixelFormat) type {
        const pixel_type = format.getComponent();
        const Component = pixel_type.toType();
        return switch (format) {
            .r => extern struct {
                r: Component,
                pub usingnamespace math.vector.ops(@This()).arithmetic;
            },
            .rg => extern struct {
                r: Component,
                g: Component,
                pub usingnamespace math.vector.ops(@This()).arithmetic;
            },
            .rgb => extern struct {
                r: Component,
                g: Component,
                b: Component,
                pub usingnamespace math.vector.ops(@This()).arithmetic;
            },
            .rgba => extern struct {
                r: Component,
                g: Component,
                b: Component,
                a: Component,
                pub usingnamespace math.vector.ops(@This()).arithmetic;
            },
        };
    }

};

pub const PixelComponent = enum(u32) {
    byte = GL_UNSIGNED_BYTE,
    signed_byte = GL_BYTE,
    short = GL_UNSIGNED_SHORT,
    signed_short = GL_SHORT,
    // int = GL_UNSIGNED_INT,
    // signed_int = GL_INT,
    float = GL_FLOAT,

    pub fn toType(comptime self: PixelComponent) type {
        return switch (self) {
            .byte => u8,
            .signed_byte => i8,
            .short => u16,
            .signed_short => i16,
            // .int => u32,
            // .signed_int => i32,
            .float => f32,
        };
    }

    pub fn fromComponentType(comptime T: type) PixelComponent {
        switch (T) {
            u8 => .byte,
            i8 => .unsigned_byte,
            u16 => .short,
            i16 => .unsigned_short,
            // u32 => .int,
            // i32 => .unsigned_int,
            f32 => .float,
            else => @compileError("invalid pixel type " ++ @typeName(T)),
        }
    }
};