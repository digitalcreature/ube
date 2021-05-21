const std = @import("std");
const math = std.math;

const vector = @import("vector.zig");
const meta = @import("meta.zig");

fn castLsb(x : f32) usize {
    return @floatToInt(usize, math.floor(x)) & 0xff;
}

pub fn noise1(pos_x: f32) f32 {
    var x = pos_x;
    var X = castLsb(pos_x);
    x -= math.floor(x);
    var u = fade(x);
    return lerp(u, grad1(perm[X], x), grad1(perm[X + 1], x - 1)) * 2;
}

pub fn noise2(pos_x: f32, pos_y: f32) f32 {
    var x = pos_x;
    var y = pos_y;
    var X = castLsb(pos_x);
    var Y = castLsb(pos_y);
    x -= math.floor(x);
    y -= math.floor(y);
    var u = fade(x);
    var v = fade(y);
    var A = (perm[X] + Y) & 0xff;
    var B = (perm[X + 1] + Y) & 0xff;
    return lerp(v, lerp(u, grad2(perm[A], x, y), grad2(perm[B], x - 1, y)), lerp(u, grad2(perm[A + 1], x, y - 1), grad2(perm[B + 1], x - 1, y - 1)));
}

// pub fn noise(Vector2 coord)
// {
//     return noise(coord.X, coord.Y);
// }

pub fn noise3(pos_x: f32, pos_y: f32, pos_z: f32) f32 {
    var x = pos_x;
    var y = pos_y;
    var z = pos_z;
    var X = castLsb(pos_x);
    var Y = castLsb(pos_y);
    var Z = castLsb(pos_z);
    x -= math.floor(x);
    y -= math.floor(y);
    z -= math.floor(z);
    var u = fade(x);
    var v = fade(y);
    var w = fade(z);
    var A = (perm[X] + Y) & 0xff;
    var B = (perm[X + 1] + Y) & 0xff;
    var AA = (perm[A] + Z) & 0xff;
    var BA = (perm[B] + Z) & 0xff;
    var AB = (perm[A + 1] + Z) & 0xff;
    var BB = (perm[B + 1] + Z) & 0xff;
    return lerp(w, lerp(v, lerp(u, grad3(perm[AA], x, y, z), grad3(perm[BA], x - 1, y, z)), lerp(u, grad3(perm[AB], x, y - 1, z), grad3(perm[BB], x - 1, y - 1, z))), lerp(v, lerp(u, grad3(perm[AA + 1], x, y, z - 1), grad3(perm[BA + 1], x - 1, y, z - 1)), lerp(u, grad3(perm[AB + 1], x, y - 1, z - 1), grad3(perm[BB + 1], x - 1, y - 1, z - 1))));
}

pub fn noise(v : anytype) f32 {
    const V = @TypeOf(v);
    return switch (@typeInfo(V)) {
        .Int, .ComptimeInt => noise1(@intToFloat(f32, v)),
        .Float, .ComptimeFloat => noise1(@floatCast(f32, v)),
        .Struct => blk: {
            const info = meta.vectorTypeInfo(V).assert();
            const ops = vector.ops(V).basic;
            const V_f32 = vector.Vector(f32, info.dimensions);
            const v_f32 = switch (@typeInfo(info.Element)) {
                .Int, .ComptimeInt => ops.intToFloat(v, V_f32),
                .Float, .ComptimeFloat => ops.floatCast(v, V_f32),
                else => unreachable,
            };
            break :blk switch (info.dimensions) {
                1 => noise1(ops.get(v, 0)),
                2 => noise2(ops.get(v, 0), ops.get(v, 1)),
                3 => noise3(ops.get(v, 0), ops.get(v, 1), ops.get(v, 2)),
                else => @compileError("only 1, 2, and 3 dimensional noise supported, cannot sample noise in " ++ std.fmt.comptimePrint("{d}", .{info.dimensions}) ++ " dimensions with " ++ @typeName(V)),
            };
        },
        else => @compileError("cannot sample noise with non vector/scalar type " ++ @typeName(V)),
    };
}

// pub fn noise(Vector3 coord)
// {
//     return noise(coord.X, coord.Y, coord.Z);
// }

// pub fn Fbm(float x, int octave)
// {
//     var f = 0.0f;
//     var w = 0.5f;
//     for (var i = 0; i < octave; i++) {
//         f += w * noise(x);
//         x *= 2.0f;
//         w *= 0.5f;
//     }
//     return f;
// }

// pub fn Fbm(Vector2 coord, int octave)
// {
//     var f = 0.0f;
//     var w = 0.5f;
//     for (var i = 0; i < octave; i++) {
//         f += w * noise(coord);
//         coord *= 2.0f;
//         w *= 0.5f;
//     }
//     return f;
// }

// pub fn Fbm(float x, float y, int octave)
// {
//     return Fbm(new Vector2(x, y), octave);
// }

// pub fn Fbm(Vector3 coord, int octave)
// {
//     var f = 0.0f;
//     var w = 0.5f;
//     for (var i = 0; i < octave; i++) {
//         f += w * noise(coord);
//         coord *= 2.0f;
//         w *= 0.5f;
//     }
//     return f;
// }

// pub fn Fbm(float x, float y, float z, int octave)
// {
//     return Fbm(new Vector3(x, y, z), octave);
// }

fn fade(t: f32) f32 {
    return t * t * t * (t * (t * 6 - 15) + 10);
}

fn lerp(t: f32, a: f32, b: f32) f32 {
    return a + t * (b - a);
}

fn grad1(hash: i32, x: f32) f32 {
    return if ((hash & 1) == 0) x else -x;
}

fn grad2(hash: i32, x: f32, y: f32) f32 {
    return (if ((hash & 1) == 0) x else -x) +
        (if ((hash & 2) == 0) y else -y);
}

fn grad3(hash: i32, x: f32, y: f32, z: f32) f32 {
    var h = hash & 15;
    var u = if (h < 8)  x else y;
    var v = if (h < 4)  y else (if (h == 12 or h == 14)  x else z);
    return grad2(h, u, v);
}

const perm = [_]u8{
    151, 160, 137, 91,  90,  15,
    131, 13,  201, 95,  96,  53,
    194, 233, 7,   225, 140, 36,
    103, 30,  69,  142, 8,   99,
    37,  240, 21,  10,  23,  190,
    6,   148, 247, 120, 234, 75,
    0,   26,  197, 62,  94,  252,
    219, 203, 117, 35,  11,  32,
    57,  177, 33,  88,  237, 149,
    56,  87,  174, 20,  125, 136,
    171, 168, 68,  175, 74,  165,
    71,  134, 139, 48,  27,  166,
    77,  146, 158, 231, 83,  111,
    229, 122, 60,  211, 133, 230,
    220, 105, 92,  41,  55,  46,
    245, 40,  244, 102, 143, 54,
    65,  25,  63,  161, 1,   216,
    80,  73,  209, 76,  132, 187,
    208, 89,  18,  169, 200, 196,
    135, 130, 116, 188, 159, 86,
    164, 100, 109, 198, 173, 186,
    3,   64,  52,  217, 226, 250,
    124, 123, 5,   202, 38,  147,
    118, 126, 255, 82,  85,  212,
    207, 206, 59,  227, 47,  16,
    58,  17,  182, 189, 28,  42,
    223, 183, 170, 213, 119, 248,
    152, 2,   44,  154, 163, 70,
    221, 153, 101, 155, 167, 43,
    172, 9,   129, 22,  39,  253,
    19,  98,  108, 110, 79,  113,
    224, 232, 178, 185, 112, 104,
    218, 246, 97,  228, 251, 34,
    242, 193, 238, 210, 144, 12,
    191, 179, 162, 241, 81,  51,
    145, 235, 249, 14,  239, 107,
    49,  192, 214, 31,  181, 199,
    106, 157, 184, 84,  204, 176,
    115, 121, 50,  45,  127, 4,
    150, 254, 138, 236, 205, 93,
    222, 114, 67,  29,  24,  72,
    243, 141, 128, 195, 78,  66,
    215, 61,  156, 180, 151,
};
