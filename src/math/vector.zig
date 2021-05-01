const std = @import("std");
const meta = std.meta;
usingnamespace @import("meta.zig");

pub fn ops(comptime Self : type) type {

    const self_info = vectorTypeInfo(Self).assert();
    const dimensions = self_info.dimensions;
    const Element = self_info.Element;
    const field_names = self_info.field_names;

    return struct {

        pub const default_format = struct {
            
            pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, stream: anytype) !void {
                try stream.writeAll("(");
                inline for (field_names) |name, i| {
                    try stream.print("{" ++ fmt ++ "}", .{@field(self, name)});
                    if (i < dimensions - 1) {
                        try stream.writeAll(", ");
                    }
                }
                try stream.writeAll(")");
            }
        };

        pub const basic = struct {

            // constructors

            pub fn new(val : [dimensions]Element) Self {
                var result : Self = undefined;
                inline for (self_info.field_names) |name, i| {
                    @field(result, name) = val[i];
                }
                return result;
            }

            pub fn from(val : anytype) Self {
                const info = vectorTypeInfo(@TypeOf(val)).assert();
                comptime info.assertSimilar(Self);
                var result : Self = undefined;
                inline for (self_info.field_names) |name, i| {
                    @field(result, name) = @field(val, info.field_names[i]);
                }
                return result;
            }

            pub fn toArray(self : Self) [dimensions]Element {
                var result : [dimensions]Element = undefined;
                inline for (field_names) |name, i| {
                    result[i] = @field(self, name);
                }
                return result;
            }

            pub fn fill(val : Element) Self {
                var result : Self = undefined;
                inline for (self_info.field_names) |name, i| {
                    @field(result, name) = val;
                }
                return result;
            }

            // element access

            pub fn getElement(self : Self, comptime i : comptime_int) Element {
                comptime if (i < 0 or i >= dimensions) comptimeError("index must be positive and less than {d} (was {d})", .{dimensions, i});
                return @field(self, field_names[i]);
            }

            pub fn setElement(self : * Self, comptime i : comptime_int, val : Element) void {
                comptime if (i < 0 or i >= dimensions) comptimeError("index must be positive and less than {d} (was {d})", .{dimensions, i});
                @field(self.*, field_names[i]) = val;
            }

            // casts

            pub fn as(self : Self, comptime V : type) V {
                const info = vectorTypeInfo(V).assert();
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (self_info.field_names) |name, i| {
                    @field(result, info.field_names[i]) = @as(info.Element, @field(self, name));
                }
                return result;
            }

            pub fn bitCast(self : Self, comptime V : type) V {
                const info = vectorTypeInfo(V).assert();
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (self_info.field_names) |name, i| {
                    @field(result, info.field_names[i]) = @bitCast(info.Element, @field(self, name));
                }
                return result;
            }
            
            pub fn floatCast(self : Self, comptime V : type) V {
                const info = vectorTypeInfo(V).assert();
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (self_info.field_names) |name, i| {
                    @field(result, info.field_names[i]) = @floatCast(info.Element, @field(self, name));
                }
                return result;
            }

            pub fn intCast(self : Self, comptime V : type) V {
                const info = vectorTypeInfo(V).assert();
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (self_info.field_names) |name, i| {
                    @field(result, info.field_names[i]) = @intCast(info.Element, @field(self, name));
                }
                return result;
            }

            pub fn truncate(self : Self, comptime V : type) V {
                const info = vectorTypeInfo(V).assert();
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (self_info.field_names) |name, i| {
                    @field(result, info.field_names[i]) = @truncate(info.Element, @field(self, name));
                }
                return result;
            }

            pub fn floatToInt(self : Self, comptime V : type) V {
                const info = vectorTypeInfo(V).assert();
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (self_info.field_names) |name, i| {
                    @field(result, info.field_names[i]) = @floatToInt(info.Element, @field(self, name));
                }
                return result;
            }

            pub fn intToFloat(self : Self, comptime V : type) V {
                const info = vectorTypeInfo(V).assert();
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (self_info.field_names) |name, i| {
                    @field(result, info.field_names[i]) = @intToFloat(info.Element, @field(self, name));
                }
                return result;
            }

        };

        pub const arithmetic = struct {
            
            pub usingnamespace basic;

            pub fn add(self : Self, rhs : anytype) Self {
                const info = vectorTypeInfo(@TypeOf(rhs)).assert();
                comptime info.assertDimensions(self_info.dimensions);
                var result : Self = self;
                inline for (self_info.field_names) |name, i| {
                    @field(result, name) += @field(rhs, info.field_names[i]);
                }
                return result;
            }

            pub fn sub(self : Self, rhs : anytype) Self {
                const info = vectorTypeInfo(@TypeOf(rhs)).assert();
                comptime info.assertDimensions(self_info.dimensions);
                var result : Self = self;
                inline for (self_info.field_names) |name, i| {
                    @field(result, name) -= @field(rhs, info.field_names[i]);
                }
                return result;
            }

            pub fn mul(self : Self, rhs : anytype) Self {
                const info = vectorTypeInfo(@TypeOf(rhs)).assert();
                comptime info.assertDimensions(self_info.dimensions);
                var result : Self = self;
                inline for (self_info.field_names) |name, i| {
                    @field(result, name) *= @field(rhs, info.field_names[i]);
                }
                return result;
            }

            pub fn div(self : Self, rhs : anytype) Self {
                const info = vectorTypeInfo(@TypeOf(rhs)).assert();
                comptime info.assertDimensions(self_info.dimensions);
                var result : Self = self;
                inline for (self_info.field_names) |name, i| {
                    @field(result, name) /= @field(rhs, info.field_names[i]);
                }
                return result;
            }

            pub fn scale(self : Self, rhs : Element) Self {
                var result : Self = self;
                inline for (self_info.field_names) |name| {
                    @field(result, name) *= rhs;
                }
                return result;
            }

            pub fn neg(self : Self) Self {
                var result : Self = self;
                inline for (self_info.field_names) |name| {
                    @field(result, name) *= -1;
                }
                return result;
            }

            pub fn sum(self : Self) self_info.Element {
                var result : self_info.Element = 0;
                inline for (self_info.field_names) |name| {
                    result += @field(self, name);
                }
                return result;
            }

            pub fn product(self : Self) self_info.Element {
                var result : self_info.Element = 1;
                inline for (self_info.field_names) |name| {
                    result *= @field(self, name);
                }
                return result;
            }

            pub fn abs(self : Self) Self {
                var result = self;
                inline for (self_info.field_names) |name| {
                    @field(result, name) = switch (@typeInfo(Element)) {
                        .Float => std.math.absFloat(@field(result, name)),
                        .Int => std.math.absInt(@field(result, name)),
                        else => @compileError("cannot find abs of " ++ @typeName(Element)),
                    };
                }
                return result;
            }
        };

        pub const linear = struct {

            pub usingnamespace arithmetic;

            pub const zero = fill(0);
            pub const one = fill(1);

            pub fn unit(comptime fieldName : [] const u8) Self {
                var result = zero;
                switch(fieldName[0]) {
                    '+' => @field(result, fieldName[1..]) = 1,
                    '-' => @field(result, fieldName[1..]) = -1,
                    else => @field(result, fieldName) = 1,
                }
                return result;
            }

            pub fn dot(self : Self, rhs : anytype) Element {
                return sum(mul(self, rhs));
            }

            pub fn len2(self : Self) Element {
                return dot(self, self);
            }

            pub fn len(self : Self) Element {
                return std.math.sqrt(len2(self));
            }

            pub fn normalize(self: Self) Self {
                var l = len(self);
                if (l != 0.0) {
                    return scale(self, 1.0 / l);
                }
                else {
                    return zero;
                }
            }

            pub fn project(self : Self, rhs : anytype) Self {
                const a = self;
                return ops(@TypeOf(rhs)).arithmetic.scale(rhs, dot(a, b) / dot(b, b));
            }

            pub fn reject(self : Self, rhs : anytype) Self {
                return sub(self, project(self, rhs));
            }

            pub usingnamespace switch(dimensions) {
                3 => struct {

                    pub fn cross(self : Self, rhs : anytype) Self {
                        const info = vectorTypeInfo(@TypeOf(rhs)).assert();
                        comptime info.assertSimilar(Self);
                        const a = toArray(self);
                        const b_ops = ops(@TypeOf(rhs)).linear;
                        const b = b_ops.toArray(rhs);
                        var result : [dimensions]Element = undefined;
                        result[0] = a[1] * b[2] - a[2] * b[1];
                        result[1] = a[2] * b[0] - a[0] * b[2];
                        result[2] = a[0] * b[1] - a[1] * b[0];
                        return new(result);
                    }

                    const V4 = Vector(Element, 4);

                    pub fn toAffinePosition(self : Self) V4 {
                        return V4.new(.{
                            @field(self, field_names[0]),
                            @field(self, field_names[1]),
                            @field(self, field_names[2]),
                            1
                        });
                    }

                    pub fn toAffineDirection(self : Self) V4 {
                        return V4.new(.{
                            @field(self, field_names[0]),
                            @field(self, field_names[1]),
                            @field(self, field_names[2]),
                            0
                        });
                    }

                    pub fn fromAffinePosition(v : anytype) Self {
                        const info = vectorTypeInfo(@TypeOf(v));
                        info.assertDimensions(4);
                        info.assertElementType(Element);
                        const w = @field(v, info.field_names[3]);
                        return new(.{
                            @field(v, info.field_names[0]) / w,
                            @field(v, info.field_names[1]) / w,
                            @field(v, info.field_names[2]) / w,
                        });
                    }

                    pub fn fromAffineDirection(v : anytype) Self {
                        const info = vectorTypeInfo(@TypeOf(v));
                        info.assertDimensions(4);
                        info.assertElementType(Element);
                        return new(.{
                            @field(v, info.field_names[0]),
                            @field(v, info.field_names[1]),
                            @field(v, info.field_names[2]), 
                        });
                    }

                },
                else => struct {},
            };

        };
    };
}

pub fn Vector(comptime Element : type, comptime dimensions : comptime_int) type {
    return switch (dimensions) {
        2 => extern struct {
            x : Element,
            y : Element,

            pub usingnamespace ops(@This()).linear;
            pub usingnamespace ops(@This()).default_format;
        },
        3 => extern struct {
            x : Element,
            y : Element,
            z : Element,

            pub usingnamespace ops(@This()).linear;
            pub usingnamespace ops(@This()).default_format;
        },
        4 => extern struct {
            x : Element,
            y : Element,
            z : Element,
            w : Element,

            pub usingnamespace ops(@This()).linear;
            pub usingnamespace ops(@This()).default_format;
        },
        else => @compileError("this function only generates 2, 3, and 4 dimensional vectors. custom structs can be made with any number of dimensions"),
    };
}

pub const glm = struct {

    pub fn Vec(comptime dimensions : comptime_int) type {
        return Vector(f32, dimensions);
    }

    pub fn BVec(comptime dimensions : comptime_int) type {
        return Vector(bool, dimensions);
    }

    pub fn IVec(comptime dimensions : comptime_int) type {
        return Vector(i32, dimensions);
    }

    pub fn UVec(comptime dimensions : comptime_int) type {
        return Vector(u32, dimensions);
    }

    pub fn DVec(comptime dimensions : comptime_int) type {
        return Vector(f64, dimensions);
    }

    pub const Vec2 = Vec(2);
    pub const Vec3 = Vec(3);
    pub const Vec4 = Vec(4);

    pub const BVec2 = BVec(2);
    pub const BVec3 = BVec(3);
    pub const BVec4 = BVec(4);

    pub const IVec2 = IVec(2);
    pub const IVec3 = IVec(3);
    pub const IVec4 = IVec(4);

    pub const UVec2 = UVec(2);
    pub const UVec3 = UVec(3);
    pub const UVec4 = UVec(4);

    pub const DVec2 = DVec(2);
    pub const DVec3 = DVec(3);
    pub const DVec4 = DVec(4);

    pub fn vec2(x : f32, y : f32) Vec2 { return Vec2.new(.{x, y}); }
    pub fn vec3(x : f32, y : f32, z : f32) Vec3 { return Vec3.new(.{x, y, z}); }
    pub fn vec4(x : f32, y : f32, z : f32, w : f32) Vec4 { return Vec4.new(.{x, y, z, w}); }

    pub fn bvec2(x : bool, y : bool) BVec2 { return BVec2.new(.{x, y}); }
    pub fn bvec3(x : bool, y : bool, z : bool) BVec3 { return BVec3.new(.{x, y, z}); }
    pub fn bvec4(x : bool, y : bool, z : bool, w : bool) BVec4 { return BVec4.new(.{x, y, z, w}); }

    pub fn ivec2(x : i32, y : i32) IVec2 { return IVec2.new(.{x, y}); }
    pub fn ivec3(x : i32, y : i32, z : i32) IVec3 { return IVec3.new(.{x, y, z}); }
    pub fn ivec4(x : i32, y : i32, z : i32, w : i32) IVec4 { return IVec4.new(.{x, y, z, w}); }

    pub fn uvec2(x : u32, y : u32) UVec2 { return UVec2.new(.{x, y}); }
    pub fn uvec3(x : u32, y : u32, z : u32) UVec3 { return UVec3.new(.{x, y, z}); }
    pub fn uvec4(x : u32, y : u32, z : u32, w : u32) UVec4 { return UVec4.new(.{x, y, z, w}); }

    pub fn dvec2(x : f64, y : f64) DVec2 { return DVec2.new(.{x, y}); }
    pub fn dvec3(x : f64, y : f64, z : f64) DVec3 { return DVec3.new(.{x, y, z}); }
    pub fn dvec4(x : f64, y : f64, z : f64, w : f64) DVec4 { return DVec4.new(.{x, y, z, w}); }

};

test "vector type info" {
    const info = vectorTypeInfo(glm.Vec3).assert();
    std.testing.expectEqual(info.dimensions, 3);
    std.testing.expectEqual(info.Element, f32);
    info.assertDimensions(3);
    info.assertElementType(f32);
    std.testing.expectEqualStrings(info.field_names[0], "x");
    std.testing.expectEqualStrings(info.field_names[1], "y");
    std.testing.expectEqualStrings(info.field_names[2], "z");
    std.testing.expectEqual(info.field_names.len, 3);
}

test "vector ops" {
    const a = glm.vec3(0, 1, 2);
    const dir = a.toAffineDirection();
    std.testing.expectEqual(dir.w, 0);
}