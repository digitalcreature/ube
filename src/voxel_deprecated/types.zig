const std = @import("std");
const math = @import("math");

usingnamespace math.glm;
usingnamespace math.meta;


pub const VoxelTypeId = u16;
pub const Voxel = u16;

pub const ByteCoords = math.vector.Vector(u8, 3);
pub const Coords = math.vector.Vector(i32, 3);

pub fn coordsToByteCoords(coords: Coords) ByteCoords {
    if (std.debug.runtime_safety) {
        comptime var i = 0;
        var byte_coords: ByteCoords = undefined;
        inline while (i < 3) : (i += 1) {
            const x = coords.get(i);
            if (x > 0xff or x < 0) {
                std.debug.panicExtra(null, null, "cannot fit coords {d} into byte coords", .{coords});
            }
            else {
                byte_coords.set(i, @truncate(u8, @bitCast(u32, x)));
            }
        }
        return byte_coords;
    }
    else {
        return .{
            .x = @truncate(u8, @bitCast(u32, coords.x)),
            .y = @truncate(u8, @bitCast(u32, coords.y)),
            .z = @truncate(u8, @bitCast(u32, coords.z)),
        };
    }
}

pub const Cardinal = math.cardinals.Cardinal3;
pub const Axis = Cardinal.Axis;