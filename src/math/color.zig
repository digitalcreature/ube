const std = @import("std");
const meta = std.meta;
const vector = @import("vector.zig");
usingnamespace @import("meta.zig");


pub fn ops(comptime Self : type) type {
    
    const self_info = vectorTypeInfo(Self).assert();
    const Element = self_info.Element;
    comptime self_info.assertDimensions(4);

    return struct {

        // pub usingnamespace vector.ops(Self).arithmetic_noformat;
        pub usingnamespace vector.ops(Self).arithmetic;

        pub const maxval : Element = switch(@typeInfo(Element)){
            .Float => 1.0,
            .Int => std.math.maxInt(Element),
            else => @compileError("colors must be numeric types, not " + @typeName(Element)),
        };

        pub const white = rgb(maxval, maxval, maxval);
        pub const black = rgb(0, 0, 0);
        pub const clear = rgba(0, 0, 0, 0);
        pub const red = rgb(maxval, 0, 0);
        pub const green = rgb(0, maxval, 0);
        pub const blue = rgb(0, 0, maxval);
        pub const teal = rgb(0, maxval, maxval);
        pub const purple = rgb(maxval, 0, maxval);
        pub const yellow = rgb(maxval, maxval, 0);

        pub fn rgb(r : Element, g : Element, b : Element) Self {
            return new(.{r, g, b, maxval});
        }

        pub fn rgba(r : Element, g : Element, b : Element, a : Element) Self {
            return new(.{r, g, b, a});
        }

        pub fn hexRGB(hex : u24) Self {
            return hexRGBA((@intCast(u32, hex) << 8) | 0xFF);
        }

        pub fn hexRGBA(hex : u32) Self {
            const r = @truncate(u8, hex >> 24);
            const g = @truncate(u8, hex >> 16);
            const b = @truncate(u8, hex >>  8);
            const a = @truncate(u8, hex      );
            switch (@typeInfo(Element)) {
                .Float => {
                    return new(.{
                        @intToFloat(Element, r) / 255.0,
                        @intToFloat(Element, g) / 255.0,
                        @intToFloat(Element, b) / 255.0,
                        @intToFloat(Element, a) / 255.0,
                    });
                },
                else => {
                    if (Element == u8) {
                        return new(.{r, g, b, a});
                    }
                    else {
                        @compileError("hex initialization only supports u8 or floating point element types, not " ++ @typeName(Element));
                    }
                },
            }
        }
    };
}

pub fn Color(comptime Element : type) type {
    return extern struct {
        r : Element,
        g : Element,
        b : Element,
        a : Element,

        pub usingnamespace ops(@This());
    };
}

pub const ColorF32 = Color(f32);
pub const ColorU8 = Color(u8);


test "hex colors" {
    std.testing.log_level = .debug;
    std.log.info("{x}", .{ColorU8.hexRGB(0xFFAABB)});
    std.log.info("{x}", .{ColorU8.hexRGBA(0xFFAABB22)});
    std.log.info("{d}", .{ColorF32.hexRGB(0xFFAABB)});
    std.log.info("{d}", .{ColorF32.hexRGBA(0xFFAABB22)});
}

test "color constants" {
    std.testing.log_level = .debug;
    std.log.info("{x:2}", .{ColorU8.white});
    std.log.info("{x:2}", .{ColorU8.green});
    std.log.info("{d}", .{ColorF32.yellow});
    std.log.info("{d}", .{ColorF32.teal});
}