const std = @import("std");
const meta = std.meta;
// const math = @import("math");
const math = @import("../math/lib.zig");

usingnamespace @import("c");
usingnamespace @import("types.zig");

pub const UniformLocation = c_int;
pub const UniformTextureUnit = Uniform(i32);
pub fn Uniform(comptime T: type) type {
    return struct {
        pub const Element = T;

        location: UniformLocation = 0,
        program: Handle = 0,

        const Self = @This();

        const element_info = UniformInfo.ElementInfo.from(Element);
        const data_info = UniformDataInfo.init(Element);

        pub usingnamespace if (data_info.len) |data_len| struct {
            pub fn set(self: Self, value: []const array.Child) void {
                const len = @intCast(c_int, value.len);
                const ptr = data_info.primitiveCPtrCast(value.ptr);
                switch (data_info.kind) {
                    .single => {
                        switch (data_info.base_type) {
                            .int => glProgramUniform1iv(self.program, self.location, len, ptr),
                            .unsigned_int => glProgramUniform1uiv(self.program, self.location, len, ptr),
                            .float => glProgramUniform1fv(self.program, self.location, len, ptr)
                        }
                    },
                    .vector => {
                        switch (data_info.base_type) {
                            .int => switch(data_info.dimensions) {
                                2 => glProgramUniform2iv(self.program, self.location, len, ptr),
                                3 => glProgramUniform3iv(self.program, self.location, len, ptr),
                                4 => glProgramUniform4iv(self.program, self.location, len, ptr),
                                else => unreachable,
                            },
                            .unsigned_int => switch(data_info.dimensions) {
                                2 => glProgramUniform2uiv(self.program, self.location, len, ptr),
                                3 => glProgramUniform3uiv(self.program, self.location, len, ptr),
                                4 => glProgramUniform4uiv(self.program, self.location, len, ptr),
                                else => unreachable,
                            },
                            .float => switch(data_info.dimensions) {
                                2 => glProgramUniform2fv(self.program, self.location, len, ptr),
                                3 => glProgramUniform3fv(self.program, self.location, len, ptr),
                                4 => glProgramUniform4fv(self.program, self.location, len, ptr),
                                else => unreachable,
                            },
                        }
                    },
                    .matrix => {
                        const ptr = element_info.primitiveCPtrCast(&value);
                        const transpose = 0;
                        switch (data_info.dimensions) {
                            2 => glProgramUniformMatrix2fv(self.program, self.location, len, transpose, ptr),
                            3 => glProgramUniformMatrix3fv(self.program, self.location, len, transpose, ptr),
                            4 => glProgramUniformMatrix4fv(self.program, self.location, len, transpose, ptr),
                            else => unreachable,
                        }
                    },
                }
            }
        }
        else struct {
            pub fn set(self: Self, value: Element) void {
                switch (data_info.kind) {
                    .single => {
                        switch (data_info.base_type) {
                            .int => glProgramUniform1i(self.program, self.location, value),
                            .unsigned_int => glProgramUniform1ui(self.program, self.location, value),
                            .float => glProgramUniform1f(self.program, self.location, value)
                        }
                    },
                    .vector => {
                        const ptr = data_info.primitiveCPtrCast(&value);
                        switch (data_info.base_type) {
                            .int => switch(data_info.dimensions) {
                                2 => glProgramUniform2iv(self.program, self.location, 1, ptr),
                                3 => glProgramUniform3iv(self.program, self.location, 1, ptr),
                                4 => glProgramUniform4iv(self.program, self.location, 1, ptr),
                                else => unreachable,
                            },
                            .unsigned_int => switch(data_info.dimensions) {
                                2 => glProgramUniform2uiv(self.program, self.location, 1, ptr),
                                3 => glProgramUniform3uiv(self.program, self.location, 1, ptr),
                                4 => glProgramUniform4uiv(self.program, self.location, 1, ptr),
                                else => unreachable,
                            },
                            .float => switch(data_info.dimensions) {
                                2 => glProgramUniform2fv(self.program, self.location, 1, ptr),
                                3 => glProgramUniform3fv(self.program, self.location, 1, ptr),
                                4 => glProgramUniform4fv(self.program, self.location, 1, ptr),
                                else => unreachable,
                            },
                        }
                    },
                    .matrix => {
                        const ptr = data_info.primitiveCPtrCast(&value);
                        const transpose = 0;
                        switch (data_info.dimensions) {
                            2 => glProgramUniformMatrix2fv(self.program, self.location, 1, transpose, ptr),
                            3 => glProgramUniformMatrix3fv(self.program, self.location, 1, transpose, ptr),
                            4 => glProgramUniformMatrix4fv(self.program, self.location, 1, transpose, ptr),
                            else => unreachable,
                        }
                    },
                }
            }
        };

    };
}

pub fn initUniforms(program_handle: Handle, comptime Uniforms: type) Uniforms {
    var uniforms: Uniforms = undefined;
    switch (@typeInfo(Uniforms)) {
        .Struct => |Struct| {
            inline for (Struct.fields) |field| {
                const name = field.name;
                _ = uniformInfo(field.field_type); // make sure this is in fact a valid Uniform() type
                @field(uniforms, name) = .{
                    .program = program_handle,
                    .location = glGetUniformLocation(program_handle, name ++ ""),
                };
            }
            return uniforms;
        },
        else => @compileError("uniforms type must be a struct, not " ++ @typeName(Uniforms)),
    }
}

const UniformDataInfo = struct {
    zig_type: type,
    base_type: BaseType,
    kind: Kind,
    dimensions: usize,
    elements: usize,
    len: ?usize,

    pub const BaseType = enum {
        int,
        unsigned_int,
        float,

        pub fn fromZigType(comptime T: type) BaseType {
            return switch (T) {
                i32 => .int,
                u32 => .unsigned_int,
                f32 => .float,
                else => @compileError("invalid uniform base type " ++ @typeName(T)),
            };
        }

        pub fn toZigType(comptime self: BaseType) type {
            return switch (self) {
                .int => i32,
                .unsigned_int => u32,
                .float => f32,
            };
        }
    };

    pub const Kind = enum {
        single,
        vector,
        matrix,
    };

    pub fn init(comptime T: type) UniformDataInfo {
        comptime var info: UniformDataInfo = undefined;
        info.zig_type = T;
        switch (@typeInfo(T)) {
            .Int, .Float => {
                info.base_type = BaseType.fromZigType(T);
                info.kind = .single;
                info.dimensions = 1;
                info.elements = 1;
                info.len = null;
            },
            .Struct => |Struct| {
                if (Struct.layout != .Extern) {
                    @compileError("only extern structs allowed for uniforms. cannot use " ++ @typeName(E));
                }
                const vector_info_opt = math.meta.vectorTypeInfo(T).option();
                const matrix_info_opt = math.meta.matrixTypeInfo(T).option();
                if (matrix_info_opt) |matrix_info| {
                    matrix_info.assertSquare();
                    switch (matrix_info.row_count) {
                        2, 3, 4 => {},
                        else => @compileError("only 2, 3, and 4 dimensional square matrices supported for uniforms, not " ++ @typeName(T)),
                    }
                    if (matrix_info.Element != f32) {
                        @compileError("only f32 matrices are supported for uniforms, not " ++ @typeName(T));
                    }
                    info.base_type = .float;
                    info.kind = .matrix;
                    info.dimensions = matrix_info.row_count;
                    info.elements = matrix_info.row_count * matrix_info.row_count;
                    info.len = null;
                }
                else if (vector_info_opt) |vector_info| {
                    switch (vector_info.dimensions) {
                        2, 3, 4 => {},
                        else => @compileError("only 2, 3, and 4 dimensional vectors supported for uniforms"),
                    }
                    info.base_type = BaseType.fromZigType(vector_info.Element);
                    info.kind = .matrix;
                    info.dimensions = vector_info.dimensions;
                    info.elements = vector_info.dimensions;
                    info.len = null;
                }
                else {
                    @compileError("only vector and matrix structs are supported for uniforms, not " ++ @typeName(T));
                }
            },
            .Array => |Array| {
                comptime var element_info = init(Array.child);
                element_info.zig_type = info.zig_type;
                element_info.len = Array.len;
            },
            else => @compileError("only single, vector, matrix, and arrays of such are valid uniform types, not " ++ @typeName(T)),
        }
        return info;
    }

    pub fn primitiveCPtrCast(comptime self: UniformDataInfo, ptr: anytype) ?*const self.base_type.toZigType() {
        return @ptrCast(?*const self.base_type.toZigType(), ptr);
    }

};

pub const UniformInfo = struct {
    Element: type,
    element_info: ElementInfo,

    pub const ElementInfo = struct {
        Primitive: type,
        kind: Kind,

        pub fn primitiveCPtrCast(comptime self: ElementInfo, ptr: anytype) ?*const self.Primitive {
            return @ptrCast(?*const self.Primitive, ptr);
        }

        pub const SingleKind = union(enum) {
            primitive: type,
            vector: math.meta.VectorTypeInfo,
            matrix: math.meta.MatrixTypeInfo,

            pub fn getPrimitiveType(comptime self: @This()) type {
                return switch (self) {
                    .primitive => |primitive| primitive,
                    .vector => |vector| vector.Element,
                    .matrix => |matrix| matrix.Element,
                };
            }
        };

        pub const Kind = union(enum) {
            single: SingleKind,
            array: ArrayKind,

            pub fn getPrimitiveType(comptime self: @This()) type {
                return switch (self) {
                    .single => |single| single.getPrimitiveType(),
                    .array => |array| array.getPrimitiveType(),
                };
            }
        };

        pub const ArrayKind = struct {
            element_kind: SingleKind,
            length: usize,
            Child: type,

            pub fn getPrimitiveType(comptime self: @This()) type {
                return self.element_kind.getPrimitiveType();
            }
        };

        fn getKind(comptime E: type) Kind {
            switch (@typeInfo(E)) {
                .Int, .Float => return .{ .single = .{ .primitive = E } },
                .Array => |Array| {
                    const element_kind = getKind(Array.child);
                    switch (element_kind) {
                        .single => |single| return .{
                            .array = .{
                                .element_kind = single,
                                .length = Array.len,
                                .Child = Array.child,
                            },
                        },
                        .array => @compileError("only single-dimensional arrays are supported for uniforms, not " ++ @typeName(E)),
                    }
                },
                .Struct => |Struct| {
                    if (Struct.layout != .Extern) {
                        @compileError("only extern structs allowed for uniforms. cannot use " ++ @typeName(E));
                    }
                    const vectorInfo = math.meta.vectorTypeInfo(E).option();
                    const matrixInfo = math.meta.matrixTypeInfo(E).option();
                    if (matrixInfo) |info| {
                        return .{
                            .single = .{
                                .matrix = info,
                            },
                        };
                    }
                    if (vectorInfo) |info| {
                        return .{
                            .single = .{
                                .vector = info,
                            },
                        };
                    }
                    @compileError("only vector and matrix structs are supported for uniforms currently. invalid struct type " ++ @typeName(E));
                },
                else => @compileError("unsupported uniform element type " ++ @typeName(E)),
            }
        }

        pub fn from(comptime E: type) ElementInfo {
            const kind = getKind(E);
            return .{
                .Primitive = kind.getPrimitiveType(),
                .kind = kind,
            };
        }
    };
};

pub fn uniformInfo(comptime U: type) UniformInfo {
    if (@hasDecl(U, "Element") and @hasField(U, "location")) {
        const Element = U.Element;
        var info: UniformInfo = undefined;
        info.Element = Element;
        info.element_info = UniformInfo.ElementInfo.from(Element);
        switch (info.element_info.Primitive) {
            i32, u32, f32 => {},
            else => |P| @compileError("uniform must have primitive type i32, u32, or f32, not " ++ @typeName(P) ++ " (for uniform type " ++ @typeName(U) ++ ")"),
        }
        const single = switch (info.element_info.kind) {
            .single => |s| s,
            .array => |array| array.element_kind,
        };
        switch (single) {
            .primitive => {},
            .vector => |vector| {
                if (vector.dimensions < 2 or vector.dimensions > 4) {
                    @compileError("vector uniforms but have 2, 3, or 4 dimensions, unlike " ++ @typeName(Element));
                }
            },
            .matrix => |matrix| {
                if (matrix.row_count != matrix.col_count) {
                    @compileError("non-square matrix uniforms are currently unsupported: " ++ @typeName(Element));
                }
                const d = matrix.row_count;
                if (d < 2 or d > 4) {
                    @compileError("matrix uniforms but have 2, 3, or 4 dimensions, unlike " ++ @typeName(Element));
                }
                if (matrix.Element != f32) {
                    @compileError("only f32 matrix uniforms supported, unlike " ++ @typeName(Element));
                }
            },
        }
        return info;
    } else {
        @compileError("must provide Uniform(T) type, not " ++ @typeName(U));
    }
}

// fn logKindInfo(comptime kind_type : [] const u8, comptime single : UniformInfo.ElementInfo.SingleKind) void {
//     switch (single) {
//         .primitive => |primitive| {
//             std.log.debug("element_info.kind.{s}.primitive: {}", .{kind_type, @typeName(primitive)});
//         },
//         .vector => |vector| {
//             std.log.debug("element_info.kind.{s}.vector.Element: {}", .{kind_type, @typeName(vector.Element)});
//             std.log.debug("element_info.kind.{s}.vector.dimensions: {d}", .{kind_type, vector.dimensions});
//         },
//         .matrix => |matrix| {
//             std.log.debug("element_info.kind.{s}.matrix.Element: {}", .{kind_type, @typeName(matrix.Element)});
//             std.log.debug("element_info.kind.{s}.matrix.row_count: {d}", .{kind_type, matrix.row_count});
//             std.log.debug("element_info.kind.{s}.matrix.col_count: {d}", .{kind_type, matrix.row_count});
//         },
//     }
// }

// fn logInfo(comptime U : type) void {
//     const info = uniformInfo(U);
//     const ei = info.element_info;
//     std.log.debug("uniform: {}", .{@typeName(U)});
//     std.log.debug("info.Element: {}", .{@typeName(info.Element)});
//     std.log.debug("element_info.Primitive: {}", .{@typeName(ei.Primitive)});
//     switch (ei.kind) {
//         .single => |single| {
//             logKindInfo("single", single);
//         },
//         .array => |array| {
//             logKindInfo("array.element_kind", array.element_kind);
//             std.log.debug("element_info.kind.array.length: {d}", .{array.length});
//         },
//     }
// }

// test "uniform infos" {
//     std.testing.log_level = .debug;
//     logInfo(Uniform(f32));
//     logInfo(Uniform([32]f32));
//     logInfo(Uniform(math.glm.Vec3));
//     logInfo(Uniform([128]math.glm.Vec2));
//     logInfo(Uniform(math.glm.Mat2));
//     logInfo(Uniform([16]math.glm.Mat4));
// }

// test "uniform set" {
//     std.testing.log_level = .debug;
//     (Uniform(f32){}).set(4);
//     (Uniform(math.glm.Vec3){}).set(math.glm.Vec3.zero);
//     (Uniform(math.glm.Mat4){}).set(math.glm.Mat4.identity);
//     (Uniform([18]f32){}).set(&[3]f32{1, 2, 3});
// }

// test "init uniforms" {
//     std.testing.log_level = .debug;
//     const Uniforms = struct {
//         model_mat : Uniform(math.glm.Mat4),
//         view_mat : Uniform(math.glm.Mat4),
//         proj_mat : Uniform(math.glm.Mat4),
//         color : Uniform(math.color.ColorF32),
//         lookup : Uniform([32]f32),
//     };
//     _ = initUniforms(32, Uniforms);

// }
