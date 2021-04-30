const std = @import("std");
const fmt = std.fmt;

fn compileError(fmt : [] const u8, args : anytype) void {
    @setEvalBranchQuota(10000);
    comptime @compileError(fmt.comptimePrint(fmt, args));
}

pub const VectorTypeInfo = struct {
    dimensions : u32,
    Element : type,
    fieldNames : []const []const u8,

    pub fn assertDimensions(comptime self : VectorTypeInfo, comptime dimensions : u32) void {
        if (self.dimensions != dimensions) {
            comptime compileError("expected {d} dimensional vector, found {d} dimensional vector", .{dimensions, self.dimensions});
        }
    }

    pub fn assertElementType(comptime self : VectorTypeInfo, comptime Element : type) void {
        if (self.Element != Element) {
            @compileError("expected " ++ @typeName(Element) ++ " vector, found " ++ @typeName(self.Element) ++ " vector");
        }
    }

    pub fn assertSimilar(comptime self : VectorTypeInfo, comptime T : type) void {
        const info = vectorTypeInfoAssert(T);
        self.assertDimensions(info.dimensions);
        self.assertElementType(info.Element);
    }
};

pub fn vectorTypeInfoError(comptime T : type) union(enum) { info : VectorTypeInfo, err : [] const u8, } {
    var info = @typeInfo(T);
    switch (info) {
        .Struct => |Struct| {
            if (Struct.layout == .Extern) {
                const fields = Struct.fields;
                if (fields.len < 1) return .{ .err = "vector struct must have at least one member" };
                const dimensions = fields.len;
                const Element = fields[0].field_type;
                comptime var i : comptime_int = 1;
                inline while (i < fields.len) : (i += 1) {
                    const ftype = fields[i].field_type;
                    if (ftype != Element) {
                        return .{ .err = "vector struct must have homogenous field types (expected "
                            ++ @typeName(Element) ++ ", found " ++ @typeName(ftype) ++ " for field " ++ fields[i].name ++ ")"};
                    }
                }
                var fieldNames : [dimensions][]const u8 = undefined;
                inline for (fields) |field, f| {
                    fieldNames[f] = field.name;
                }
                return .{ .info = .{ .dimensions = dimensions, .Element = Element, .fieldNames = fieldNames[0..] }};
            }
            else {
                return .{ .err = "vector struct must be extern" } ;
            }
        },
        else => return .{ .err = "vector type must be a struct, not " ++ @typeName(T)},
    }
}

pub fn vectorTypeInfoAssert(comptime T : type) VectorTypeInfo {
    switch (vectorTypeInfoError(T)) {
        .info => |info| return info,
        .err => |err| @compileError(err),
    }
}

pub fn vectorTypeInfo(comptime T : type) ?VectorTypeInfo {
    switch (vectorTypeInfoError(T)) {
        .info => |info| return info,
        .err => |err| return null,
    }
}

pub fn ops(comptime Self : type) type {

    const selfInfo = vectorTypeInfoAssert(Self);
    const dimensions = selfInfo.dimensions;
    const Element = selfInfo.Element;
    const fieldNames = selfInfo.fieldNames;

    return struct {

        pub const basic = struct {

            // constructors

            pub fn new(val : [dimensions]Element) Self {
                var result : Self = undefined;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, name) = val[i];
                }
                return result;
            }

            pub fn from(val : anytype) Self {
                const info = vectorTypeInfoAssert(@TypeOf(val));
                comptime info.assertSimilar(Self);
                var result : Self = undefined;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, name) = @field(val, info.fieldNames[i]);
                }
                return result;
            }

            pub fn fill(val : Element) Self {
                var result : Self = undefined;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, name) = val;
                }
                return result;
            }

            // element access

            pub fn getElement(self : Self, comptime i : comptime_int) Element {
                comptime if (i < 0 or i >= dimensions) comptimeError("index must be positive and less than {d} (was {d})", .{dimensions, i});
                return @field(self, fieldNames[i]);
            }

            pub fn setElement(self : * Self, comptime i : comptime_int, val : Element) void {
                comptime if (i < 0 or i >= dimensions) comptimeError("index must be positive and less than {d} (was {d})", .{dimensions, i});
                @field(self.*, fieldNames[i]) = val;
            }

            // casts

            pub fn as(self : Self, comptime V : type) V {
                const info = vectorTypeInfoAssert(V);
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, info.fieldNames[i]) = @as(info.Element, @field(self, name));
                }
                return result;
            }

            pub fn bitCast(self : Self, comptime V : type) V {
                const info = vectorTypeInfoAssert(V);
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, info.fieldNames[i]) = @bitCast(info.Element, @field(self, name));
                }
                return result;
            }
            
            pub fn floatCast(self : Self, comptime V : type) V {
                const info = vectorTypeInfoAssert(V);
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, info.fieldNames[i]) = @floatCast(info.Element, @field(self, name));
                }
                return result;
            }

            pub fn intCast(self : Self, comptime V : type) V {
                const info = vectorTypeInfoAssert(V);
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, info.fieldNames[i]) = @intCast(info.Element, @field(self, name));
                }
                return result;
            }

            pub fn truncate(self : Self, comptime V : type) V {
                const info = vectorTypeInfoAssert(V);
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, info.fieldNames[i]) = @truncate(info.Element, @field(self, name));
                }
                return result;
            }

            pub fn floatToInt(self : Self, comptime V : type) V {
                const info = vectorTypeInfoAssert(V);
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, info.fieldNames[i]) = @floatToInt(info.Element, @field(self, name));
                }
                return result;
            }

            pub fn intToFloat(self : Self, comptime V : type) V {
                const info = vectorTypeInfoAssert(V);
                comptime info.assertDimensions(dimensions);
                var result : V = undefined;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, info.fieldNames[i]) = @intToFloat(info.Element, @field(self, name));
                }
                return result;
            }

        };

        pub const math = struct {
            
            pub usingnamespace basic;

            pub fn add(self : Self, rhs : anytype) Self {
                const info = vectorTypeInfoAssert(@TypeOf(rhs));
                comptime info.assertDimensions(selfInfo.dimensions);
                var result : Self = self;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, name) += @field(rhs, info.fieldNames[i]);
                }
                return result;
            }

            pub fn sub(self : Self, rhs : anytype) Self {
                const info = vectorTypeInfoAssert(@TypeOf(rhs));
                comptime info.assertDimensions(selfInfo.dimensions);
                var result : Self = self;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, name) -= @field(rhs, info.fieldNames[i]);
                }
                return result;
            }

            pub fn mul(self : Self, rhs : anytype) Self {
                const info = vectorTypeInfoAssert(@TypeOf(rhs));
                comptime info.assertDimensions(selfInfo.dimensions);
                var result : Self = self;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, name) *= @field(rhs, info.fieldNames[i]);
                }
                return result;
            }

            pub fn div(self : Self, rhs : anytype) Self {
                const info = vectorTypeInfoAssert(@TypeOf(rhs));
                comptime info.assertDimensions(selfInfo.dimensions);
                var result : Self = self;
                inline for (selfInfo.fieldNames) |name, i| {
                    @field(result, name) /= @field(rhs, info.fieldNames[i]);
                }
                return result;
            }

            pub fn scale(self : Self, rhs : Element) Self {
                var result : Self = self;
                inline for (selfInfo.fieldNames) |name| {
                    @field(result, name) *= rhs;
                }
                return result;
            }

            pub fn neg(self : Self) Self {
                var result : Self = self;
                inline for (selfInfo.fieldNames) |name| {
                    @field(result, name) *= -1;
                }
                return result;
            }

            pub fn sum(self : Self) selfInfo.Element {
                var result : selfInfo.Element = 0;
                inline for (selfInfo.fieldNames) |name| {
                    result += @field(self, name);
                }
                return result;
            }

            pub fn product(self : Self) selfInfo.Element {
                var result : selfInfo.Element = 1;
                inline for (selfInfo.fieldNames) |name| {
                    result *= @field(self, name);
                }
                return result;
            }

            pub fn abs(self : Self) Self {
                var result = self;
                inline for (selfInfo.fieldNames) |name| {
                    @field(result, name) = switch (@typeInfo(Element)) {
                        .Float => std.math.absFloat(@field(result, name)),
                        .Int => std.math.absInt(@field(result, name)),
                        else => @compileError("cannot find abs of " ++ @typeName(Element)),
                    };
                }
                return result;
            }
        };

        pub const glm = struct {

            pub usingnamespace math;

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
                return self.mul(rhs).sum();
            }

            pub fn len2(self : Self) Element {
                return self.dot(self);
            }

            pub fn len(self : Self) Element {
                return std.math.sqrt(self.len2());
            }

            pub fn normalize(self: Self) Self {
                var len = self.len();
                if (len != 0.0) {
                    return self.scale(1.0 / len);
                }
                else {
                    return zero;
                }
            }

            pub fn project(self : Self, rhs : anytype) Self {
                const a = self;
                const b = from(rhs);
                return b.scale(a.dot(b) / b.dot(b));
            }

            pub fn reject(self : Self, rhs : anytype) Self {
                return self.sub(self.project(rhs));
            }

            pub usingnamespace switch(dimensions) {
                3 => struct {

                    pub fn cross(self : Self, rhs : anytype) Self {
                        const info = vectorTypeInfoAssert(@TypeOf(rhs));
                        comptime info.assertSimilar(Self);
                        const a = self;
                        const b = from(rhs);
                        var result : Self = undefined;
                        result.set(0, a.get(1) * b.get(2) - a.get(2) * b.get(1));
                        result.set(1, a.get(2) * b.get(0) - a.get(0) * b.get(2));
                        result.set(2, a.get(0) * b.get(1) - a.get(1) * b.get(0));
                        return result;
                    }

                },
                else => struct {},
            };

        };
    };
}

pub fn Vec(comptime Element : type, comptime dimensions : comptime_int) type {
    return switch (dimensions) {
        2 => extern struct {
            x : Element,
            y : Element,

            pub usingnamespace ops(@This()).glm;
        },
        3 => extern struct {
            x : Element,
            y : Element,
            z : Element,

            pub usingnamespace ops(@This()).glm;
        },
        4 => extern struct {
            x : Element,
            y : Element,
            z : Element,
            w : Element,

            pub usingnamespace ops(@This()).glm;
        },
        else => @compileError("this function only generates 2, 3, and 4 dimensional vectors. custom structs can be made with any number of dimensions"),
    };
}

test "vector type info" {
    const V3f = Vec(f32, 3);
    const info = vectorTypeInfoAssert(V3f);
    std.testing.expectEqual(info.dimensions, 3);
    std.testing.expectEqual(info.Element, f32);
    info.assertDimensions(3);
    info.assertElementType(f32);
    std.testing.expectEqual(info.fieldNames[0], "x");
    std.testing.expectEqual(info.fieldNames[1], "y");
    std.testing.expectEqual(info.fieldNames[2], "z");
    std.testing.expectEqual(info.fieldNames.len, 3);
}

test "vector ops" {
    const V3f = Vec(f32, 3);
    std.testing.expectEqual(V3f.unit("x").x, 1);
    std.testing.expectEqual(V3f.unit("+y").y, 1);
    std.testing.expectEqual(V3f.unit("-z").z, -1);

}