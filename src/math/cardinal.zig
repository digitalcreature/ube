const std = @import("std");
const enums = @import("utils").enums;
const EnumIndexedArray = enums.EnumIndexedArray;
// const meta = @import("meta.zig");

const TypeInfo = std.builtin.TypeInfo;

fn AxisMixin(comptime Self: type, comptime dimensions: usize) type {

    return struct {

        pub const values_array = enums.valuesArray(Self);

        pub fn toIndex(self: Self) usize {
            return @intCast(usize, @enumToInt(self));
        }

        pub fn IndexedArray(comptime T: type) type {
            return EnumIndexedArray(T, Self);
        }

    };

}

fn CardinalMixin(comptime Self: type, comptime dimensions: usize) type {
    return struct {
        
        pub const values_array = enums.valuesArray(Self);

        pub const count = dimensions * 2;

        const Axis = Self.Axis;
        pub const Sign = enum {
            positive = 0,
            negative = 1,


            /// if T is signed: return 1 if positive, -1 if negative
            /// if T is unsigned: return 1 if positive, 0 if negative
            pub fn toScalar(self: Sign, comptime T: type) T {
                const is_signed = switch (@typeInfo(T)) {
                    .Int => |Int| Int.is_signed,
                    else => true,
                };
                return switch (self) {
                    .positive => 1,
                    .negative => if (is_signed) -1 else 0,
                };
            }
        };

        pub fn IndexedArray(comptime T: type) type {
            return EnumIndexedArray(T, Self);
        }

        pub fn init(a: Axis, s: Sign) Self {
            return @intToEnum(Self, a.toIndex() + dimensions * @enumToInt(s));
        }

        pub fn sign(self: Self) Sign {
            return @intToEnum(Sign, @truncate(std.meta.TagType(Sign), @enumToInt(self) / dimensions));
        }

        pub fn axis(self: Self) Axis {
            return @intToEnum(Axis, @truncate(std.meta.TagType(Axis), @enumToInt(self) % dimensions));
        }

        pub fn negate(self: Self) Self {
            return @intToEnum(Self, (@enumToInt(self) + dimensions) % count);
        }

        pub fn toInt(self: Self, comptime T: type) T {
            return @intCast(T, @enumToInt(self));
        }
        

    };

}

fn leastBitsForNumber(n: usize) usize {
    var bits: usize = 0;
    var x = n;
    while (x > 0) : (x >>= 1) {
        bits += 1;
    }
    return bits;
}

pub fn Cardinal(comptime dimensions: usize) type {
    return switch (dimensions) {
        1 => Cardinal1,
        2 => Cardinal2,
        3 => Cardinal3,
        4 => Cardinal4,
        else => @compileError("cardinals only supported in 1, 2, 3, and 4 dimensions"),
    };
}

const CardinalTag = u32;

pub const Cardinal1 = enum { //(CardinalTag) {
    x_p = 0,
    x_n = 1,

    pub const Axis = enum {
        x = 0,
        
        pub usingnamespace AxisMixin(@This(), 1);
    };

    pub usingnamespace CardinalMixin(@This(), 1);

};

pub const Cardinal2 = enum { //(CardinalTag) {
    x_p = 0,
    y_p = 1,
    x_n = 2,
    y_n = 3,

    pub const Axis = enum {
        x = 0,
        y = 1,

        pub usingnamespace AxisMixin(@This(), 2);
    };

    pub usingnamespace CardinalMixin(@This(), 2);

};

pub const Cardinal3 = enum { //(CardinalTag) {
    x_p = 0,
    y_p = 1,
    z_p = 2,
    x_n = 3,
    y_n = 4,
    z_n = 5,

    pub const Axis = enum {
        x = 0,
        y = 1,
        z = 2,

        pub usingnamespace AxisMixin(@This(), 3);
    };

    pub usingnamespace CardinalMixin(@This(), 3);

};

pub const Cardinal4 = enum { //(CardinalTag) {
    x_p = 0,
    y_p = 1,
    z_p = 2,
    w_p = 3,
    x_n = 4,
    y_n = 5,
    z_n = 6,
    w_n = 7,

    pub const Axis = enum {
        x = 0,
        y = 1,
        z = 2,
        w = 3,

        pub usingnamespace AxisMixin(@This(), 4);
    };

    pub usingnamespace CardinalMixin(@This(), 4);

};