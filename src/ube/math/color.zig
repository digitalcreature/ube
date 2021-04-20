const std = @import("std");
const math = @import("math.zig");
const mathf = math.mathf;
usingnamespace @import("vector.zig");
pub const ColorI = Vec(4, u8);
pub const ColorF = Vec(4, f32);

pub fn rgbi(r : u8, g : u8, b : u8) ColorI {
    return ColorI.new(r, g, b, 255);
}

pub fn rgbai(r : u8, g : u8, b : u8, a : u8) ColorI {
    return ColorI.new(r, g, b, a);
}

pub fn rgbf(r : f32, g : f32, b : f32) ColorF {
    return ColorF.new(r, g, b, 1);
}

pub fn rgbaf(r : f32, g : f32, b : f32, a : f32) ColorF {
    return ColorF.new(r, g, b, a);
}

pub fn casti(color : ColorF) ColorI {
    return ColorI.new(
        @floatToInt(u8, mathf.clamp01(color.r) * 255),
        @floatToInt(u8, mathf.clamp01(color.g) * 255),
        @floatToInt(u8, mathf.clamp01(color.b) * 255),
        @floatToInt(u8, mathf.clamp01(color.a) * 255),
    );
}

pub fn castf(color : ColorI) ColorF {
    return ColorF.new(
        @intToFloat(f32, color.r) / 255,
        @intToFloat(f32, color.g) / 255,
        @intToFloat(f32, color.b) / 255,
        @intToFloat(f32, color.a) / 255,
    );
}

pub fn hexrgbi(hex : u32) ColorI {
    const vals = @bitCast([4] u8, hex);
    return ColorI.new(vals[3], vals[2], vals[1], 255);
}

pub fn hexrgbai(hex : u32) ColorI {
    const vals = @bitCast([4] u8, hex);
    return ColorI.new(vals[2], vals[1], vals[0], 255);
}

pub fn hexrgbf(hex : u32) ColorI {
    return castf(hexrgbi(u32));
}

pub fn hexrgbaf(hex : u32) ColorI {
    return castf(hexrgbai(u32));
}


const expect = std.testing.expect;
test "hex colors" {
    const color = hexrgbi(0xFF100000);
    expect(color.x == 0xFF);
    expect(color.y == 0x10);
    expect(color.z == 0x00);
    expect(color.w == 0xFF);
}