const zlm = @import("zlm.zig");

const zlm_f32 = zlm.specializeOn(f32);
const zlm_i32 = zlm.specializeOn(i32);

pub const V2f = zlm_f32.Vec2;
pub const v2f = zlm_f32.vec2;
pub const V3f = zlm_f32.Vec3;
pub const v3f = zlm_f32.vec3;
pub const V4f = zlm_f32.Vec4;
pub const v4f = zlm_f32.vec4;

pub const V2i = zlm_i32.Vec2;
pub const v2i = zlm_i32.vec2;
pub const V3i = zlm_i32.Vec3;
pub const v3i = zlm_i32.vec3;
pub const V4i = zlm_i32.Vec4;
pub const v4i = zlm_i32.vec4;

pub const M2x2f = zlm_f32.Mat2;
pub const M3x3f = zlm_f32.Mat3;
pub const M4x4f = zlm_f32.Mat4;

pub fn Vec(comptime Dimensions : usize, comptime Real : type) type {
    const z = zlm.specializeOn(Real);
    return switch (Dimensions) {
        2 => z.Vec2,
        3 => z.Vec3,
        4 => z.Vec4,
        else => @compileError("only 2, 3, and 4 dimensional vectors are supported"),
    };
}
