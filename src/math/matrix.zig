const std = @import("std");
const vector = @import("vector.zig");
usingnamespace @import("meta.zig");


pub fn ops(comptime Self : type) type {
    const self_info = matrixTypeInfo(Self).assert();
    self_info.assertSquare(); // for now, we're only supporting square matrices
    const field_name = self_info.field_name;
    const dimensions = self_info.row_count;
    const Element = self_info.Element;

    const FieldArray = [dimensions][dimensions]Element;

    return struct {

        pub const zero = fill(0);
        pub const identity = blk: {
            var result = zero;
            comptime var rc : comptime_int = 0;
            inline while(rc < dimensions) : (rc += 1) {
                @field(result, field_name)[rc][rc] = 1;
            }
            break :blk result;
        };

        pub fn new(fields : FieldArray) Self {
            var result : Self = undefined;
            @field(result, field_name) = fields;
            return result;
        }

        pub fn fill(val : Element) Self {
            var fields : FieldArray = undefined;
            comptime var r : comptime_int = 0;
            inline while(r < dimensions) : (r += 1) {
                comptime var c : comptime_int = 0;
                inline while(c < dimensions) : (c += 1) {
                    fields[r][c] = val;
                }
            }
            return new(fields);
        }

        // transform a vector of the same dimensions and element type
        pub fn transform(self : Self, vec : anytype) @TypeOf(vec) {
            const V = @TypeOf(vec);
            const info = vectorTypeInfo(V).assert();
            info.assertElementType(Element);
            info.assertDimensions(dimensions);
            const vals = @field(self, field_name);
            // grab the vector ops mixin for this type so its easier to work with
            const vops = vector.ops(V).linear;
            var result : [dimensions]Element = [_]Element{0} ** dimensions;
            comptime var c : comptime_int = 0;
            inline while(c < dimensions) : (c += 1) {
                comptime var r : comptime_int = 0;
                inline while(r < dimensions) : (r += 1) {
                    result[r] += @field(vec, info.field_names[c]) * vals[r][c];
                }
            }
            return vops.new(result);
        }

        pub fn mul(self : Self, rhs : anytype) Self {
            info = matrixTypeInfo(@typeof(rhs)).assert();
            info.assertSimilar(Self);
            const a = @field(self, field_name);
            const b = @field(rhs, info.field_name);
            var result : FieldArray = undefined;

            comptime var r = 0;
            inline while (r < dimensions) : (r += 1) {
                comptime var c = 0;
                inline while (c < dimensions) : (c += 1) {
                    var sum : Element = 0;
                    comptime var i = 0;
                    inline while (i < dimensions) : (i += 1) {
                        sum += a[r][i] * b[i][c];
                    }
                    result[r][c] = sum;
                }
            }
            return Self.new(result);
        }

        pub fn transpose(self : Self) Self {
            var result : FieldArray = undefined;
            const vals = @field(self, field_name);
            comptime r = 0;
            inline while (r < dimensions) : (r += 1) {
                comptime c = 0;
                inline while (c < dimensions) : (c += 1) {
                    result[r][c] = vals[c][r];
                }
            }
            return new(result);
        }
        
        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, stream: anytype) !void {
            try stream.writeAll("\n[");
            const vals = @field(self, field_name);
            comptime var r : comptime_int = 0;
            inline while (r < dimensions) : (r += 1) {
                if (r > 0) try stream.writeAll(" ");
                try stream.writeAll("[");
                const row = vals[r];
                comptime var c : comptime_int = 0;
                inline while(c < dimensions) : (c += 1) {
                    try stream.print("{" ++ fmt ++ "}", .{row[c]});
                    if (c < dimensions - 1) {
                        try stream.writeAll(", ");
                    }
                }
                try stream.writeAll("]");
                if (r < dimensions - 1) {
                    try stream.writeAll("\n");
                }
                
            }
            try stream.writeAll("]");
        }


        // dimension specific methods
        pub usingnamespace switch(dimensions) {
            2 => struct {

            },
            3 => struct {
                
            },
            4 => struct {
                
                pub fn transformPosition(self : Self, vec : anytype) @TypeOf(vec) {
                    const info = vectorTypeInfo(vec).assert();
                    info.assertDimensions(3);
                    info.assertElementType(Element);
                    const vops = vector.ops(@TypeOf(vec)).linear;
                    return vops.fromAffinePosition(transform(self, vops.toAffinePosition(vec)));
                }
                
                pub fn transformDirection(self : Self, vec : anytype) @TypeOf(vec) {
                    const info = vectorTypeInfo(vec).assert();
                    info.assertDimensions(3);
                    info.assertElementType(Element);
                    const vops = vector.ops(@TypeOf(vec)).linear;
                    return vops.fromAffineDirection(transform(self, vops.toAffineDirection(vec)));
                }

                /// Creates a look-at matrix.
                /// The matrix will create a transformation that can be used
                /// as a camera transform.
                /// the camera is located at `eye` and will look into `direction`.
                /// `up` is the direction from the screen center to the upper screen border.
                pub fn createLook(eye: anytype, direction: anytype, up: anytype) Self {
                    const eye_ = vector.Vector(Element, 3).from(eye);
                    const direction_ = vector.Vector(Element, 3).from(direction);
                    const up_ = vector.Vector(Element, 3).from(up);
                    const f = direction_.normalize();
                    const s = up_.cross(f).normalize();
                    const u = f.cross(s);

                    var result : FieldArray = @field(identity, field_name);
                    result[0][0] = s.x;
                    result[1][0] = s.y;
                    result[2][0] = s.z;
                    result[0][1] = u.x;
                    result[1][1] = u.y;
                    result[2][1] = u.z;
                    result[0][2] = f.x;
                    result[1][2] = f.y;
                    result[2][2] = f.z;
                    result[3][0] = -s.dot(eye);
                    result[3][1] = -u.dot(eye);
                    result[3][2] = -f.dot(eye);
                    return new(result);
                }

                /// Creates a look-at matrix.
                /// The matrix will create a transformation that can be used
                /// as a camera transform.
                /// the camera is located at `eye` and will look at `center`.
                /// `up` is the direction from the screen center to the upper screen border.
                pub fn createLookAt(eye: anytype, center: anytype, up: anytype) Self {
                    return createLook(eye, vector.ops(@TypeOf(center)).arithmetic.sub(center, eye), up);
                }

                /// creates a perspective transformation matrix.
                /// `fov` is the field of view in radians,
                /// `aspect` is the screen aspect ratio (width / height)
                /// `near` is the distance of the near clip plane, whereas `far` is the distance to the far clip plane.
                pub fn createPerspective(fov: Element, aspect: Element, near: Element, far: Element) Self {
                    std.debug.assert(std.math.fabs(aspect - 0.001) > 0);

                    const tanHalfFovy = std.math.tan(fov / 2);

                    var result = @field(zero, field_name);
                    result[0][0] = 1.0 / (aspect * tanHalfFovy);
                    result[1][1] = 1.0 / (tanHalfFovy);
                    result[2][2] = far / (far - near);
                    result[2][3] = 1;
                    result[3][2] = -(far * near) / (far - near);
                    return new(result);
                }

                /// creates an orthogonal projection matrix.
                /// `left`, `right`, `bottom` and `top` are the borders of the screen whereas `near` and `far` define the
                /// distance of the near and far clipping planes.
                pub fn createOrthogonal(left: Element, right: Element, bottom: Element, top: Element, near: Element, far: Element) Self {
                    var result = @field(identity, field_name);
                    result[0][0] = 2 / (right - left);
                    result[1][1] = 2 / (top - bottom);
                    result[2][2] = 1 / (far - near);
                    result[3][0] = -(right + left) / (right - left);
                    result[3][1] = -(top + bottom) / (top - bottom);
                    result[3][2] = -near / (far - near);
                    return new(result);
                }

                /// creates a rotation matrix around a certain axis.
                pub fn createAxisAngle(axis: anytype, angle: Element) Self {
                    const info = vectorTypeInfo(@TypeOf(axis)).assert();
                    comptime info.assertDimensions(3);
                    comptime info.assertElementType(Element);
                    const cos = std.math.cos(angle);
                    const sin = std.math.sin(angle);
                    const x = @field(axis, info.field_names[0]);
                    const y = @field(axis, info.field_names[1]);
                    const z = @field(axis, info.field_names[2]);

                    return new(.{
                        .{ cos + x * x * (1 - cos), x * y * (1 - cos) - z * sin, x * z * (1 - cos) + y * sin, 0 },
                        .{ y * x * (1 - cos) + z * sin, cos + y * y * (1 - cos), y * z * (1 - cos) - x * sin, 0 },
                        .{ z * x * (1 * cos) - y * sin, z * y * (1 - cos) + x * sin, cos + z * z * (1 - cos), 0 },
                        .{ 0, 0, 0, 1 },
                    });
                }

                /// creates matrix that will scale a homogeneous matrix.
                pub fn createUniformScale(scale: Element) Self {
                    return createScaleXYZ(scale, scale, scale);
                }

                /// Creates a non-uniform scaling matrix
                pub fn createScaleXYZ(x: Element, y: Element, z: Element) Self {
                    return new(.{
                        .{ x, 0, 0, 0 },
                        .{ 0, y, 0, 0 },
                        .{ 0, 0, z, 0 },
                        .{ 0, 0, 0, 1 },
                    });
                }

                /// Creates a non-uniform scaling matrix
                pub fn createScale(scale : anytype) Self {
                    const info = vectorTypeInfo(@TypeOf(scale)).assert();
                    comptime info.assertDimensions(3);
                    comptime info.assertElementType(Element);
                    const x = @field(scale, info.field_names[0]);
                    const y = @field(scale, info.field_names[1]);
                    const z = @field(scale, info.field_names[2]);
                    return createScaleXYZ(x, y, z);
                }

                /// creates matrix that will translate a homogeneous matrix.
                pub fn createTranslationXYZ(x: Element, y: Element, z: Element) Self {
                    return new(.{
                        .{ 1, 0, 0, 0 },
                        .{ 0, 1, 0, 0 },
                        .{ 0, 0, 1, 0 },
                        .{ x, y, z, 1 },
                    });
                }

                /// creates matrix that will scale a homogeneous matrix.
                pub fn createTranslation(translation: anytype) Self {
                    const info = vectorTypeInfo(@TypeOf(translation)).assert();
                    comptime info.assertDimensions(3);
                    comptime info.assertElementType(Element);
                    const x = @field(translation, info.field_names[0]);
                    const y = @field(translation, info.field_names[1]);
                    const z = @field(translation, info.field_names[2]);
                    return createTranslationXYZ(x, y, z);
                } 

                /// Batch matrix multiplication. Will multiply all matrices from "first" to "last".
                pub fn batchMul(items: []const Self) Self {
                    if (items.len == 0)
                        return identity;
                    if (items.len == 1)
                        return items[0];
                    var value = items[0];
                    var i: usize = 1;
                    while (i < items.len) : (i += 1) {
                        value = mul(value, items[i]);
                    }
                    return value;
                }

                pub fn invert(self: Self) ?Self {
                    // https://github.com/stackgl/gl-mat4/blob/master/invert.js
                    const a = @bitCast([16]Element, @field(self, field_name));

                    const a00 = a[0];
                    const a01 = a[1];
                    const a02 = a[2];
                    const a03 = a[3];
                    const a10 = a[4];
                    const a11 = a[5];
                    const a12 = a[6];
                    const a13 = a[7];
                    const a20 = a[8];
                    const a21 = a[9];
                    const a22 = a[10];
                    const a23 = a[11];
                    const a30 = a[12];
                    const a31 = a[13];
                    const a32 = a[14];
                    const a33 = a[15];

                    const b00 = a00 * a11 - a01 * a10;
                    const b01 = a00 * a12 - a02 * a10;
                    const b02 = a00 * a13 - a03 * a10;
                    const b03 = a01 * a12 - a02 * a11;
                    const b04 = a01 * a13 - a03 * a11;
                    const b05 = a02 * a13 - a03 * a12;
                    const b06 = a20 * a31 - a21 * a30;
                    const b07 = a20 * a32 - a22 * a30;
                    const b08 = a20 * a33 - a23 * a30;
                    const b09 = a21 * a32 - a22 * a31;
                    const b10 = a21 * a33 - a23 * a31;
                    const b11 = a22 * a33 - a23 * a32;

                    // Calculate the determinant
                    var det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

                    if (std.math.approxEqAbs(Element, det, 0, 1e-8)) {
                        return null;
                    }
                    det = 1.0 / det;

                    const result = [16]Element{
                        (a11 * b11 - a12 * b10 + a13 * b09) * det, // 0
                        (a02 * b10 - a01 * b11 - a03 * b09) * det, // 1
                        (a31 * b05 - a32 * b04 + a33 * b03) * det, // 2
                        (a22 * b04 - a21 * b05 - a23 * b03) * det, // 3
                        (a12 * b08 - a10 * b11 - a13 * b07) * det, // 4
                        (a00 * b11 - a02 * b08 + a03 * b07) * det, // 5
                        (a32 * b02 - a30 * b05 - a33 * b01) * det, // 6
                        (a20 * b05 - a22 * b02 + a23 * b01) * det, // 7
                        (a10 * b10 - a11 * b08 + a13 * b06) * det, // 8
                        (a01 * b08 - a00 * b10 - a03 * b06) * det, // 9
                        (a30 * b04 - a31 * b02 + a33 * b00) * det, // 10
                        (a21 * b02 - a20 * b04 - a23 * b00) * det, // 11
                        (a11 * b07 - a10 * b09 - a12 * b06) * det, // 12
                        (a00 * b09 - a01 * b07 + a02 * b06) * det, // 13
                        (a31 * b01 - a30 * b03 - a32 * b00) * det, // 14
                        (a20 * b03 - a21 * b01 + a22 * b00) * det, // 15
                    };
                    return new(@bitCast([4][4]Element, out));
                }

            },
            else => struct {}
        };
    };
}

pub fn Matrix(comptime Element : type, comptime dimensions : comptime_int) type {
    return extern struct {
        fields : [dimensions][dimensions]Element,
        pub usingnamespace ops(@This());
    };
}

pub const glm = struct {

    pub const Mat2 = Matrix(f32, 2);
    pub const Mat3 = Matrix(f32, 3);
    pub const Mat4 = Matrix(f32, 4);

    pub const DMat2 = Matrix(f64, 2);
    pub const DMat3 = Matrix(f64, 3);
    pub const DMat4 = Matrix(f64, 4);

};

test "matrices" {
    const m = Matrix(f32, 3).identity;
    std.testing.expectEqual(m.fields[0][0], 1);
    std.testing.expectEqual(m.fields[1][1], 1);
    std.testing.expectEqual(m.fields[2][2], 1);
    std.testing.expectEqual(m.fields[1][2], 0);
}

test "transform" {
    const a = vector.glm.vec3(1, 2, 3);
    const b = Matrix(f32, 3).identity.transform(a);
    std.testing.expectEqual(a, b);
}