const std = @import("std");
const math = @import("math");

usingnamespace math.glm;

pub const VoxelTypeID = u8;

pub const ByteCoords = math.vector.Vector(u8, 3);
pub const Coords = math.vector.Vector(i32, 3);

pub fn coordsToByteCoords(coords: Coords) !ByteCoords {
    comptime var i = 0;
    var byte_coords: ByteCoords = undefined;
    inline while (i < 3) : (i += 1) {
        const x = coords.get(i);
        if (x > 0xff or x < 0) {
            return error.CoordsOutOfCast;
        }
        else {
            byte_coords.set(i, @truncate(u8, @bitCast(u32, x)));
        }
    }
    return byte_coords;
}