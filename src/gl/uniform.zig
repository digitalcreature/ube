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
        pub const Data = T;

        location: UniformLocation = 0,
        program: Handle = 0,

        const Self = @This();

        const data_info = UniformDataInfo.init(Data);

        const Value = if (data_info.len != null)
            []const data_info.zig_type
        else
            data_info.zig_type;

        pub fn set(self: Self, value: Value) void {
            const Ptr = *const data_info.base_type.toZigType();
            var ptr: Ptr = undefined;
            var len: i32 = undefined;
            if (data_info.len != null) {
                ptr = @ptrCast(Ptr, value.ptr);
                len = @intCast(i32, value.len);
            }
            else {
                ptr = @ptrCast(Ptr, &value);
                len = 1;
            }
            switch (data_info.kind) {
                .single => {
                    switch (data_info.base_type) {
                        .int => glProgramUniform1iv(self.program, self.location, len, ptr),
                        .unsigned_int => glProgramUniform1uiv(self.program, self.location, len, ptr),
                        .float => glProgramUniform1fv(self.program, self.location, len, ptr),
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

    };
}

pub fn initUniforms(program_handle: Handle, comptime Uniforms: type) Uniforms {
    var uniforms: Uniforms = undefined;
    inline for (@typeInfo(Uniforms).Struct.fields) |field| {
        @field(uniforms, field.name) = .{
            .program = program_handle,
            .location = glGetUniformLocation(program_handle, field.name ++ ""),
        };
    }
    return uniforms;
}

const TypeId = @import("builtin").TypeId;
pub fn createUniformsStructFromDeclarations(comptime decls: []const type) type {
    comptime {
        var count = 0;
        for (decls) |decl| {
            const info = @typeInfo(decl);
            if (info != .Struct) @compileError("uniform decls must be structs, not " ++ @typeName(decl));
            count += info.Struct.fields.len;
        }
        var fields: [count]TypeId.StructField = undefined;
        var i = 0;
        for (decls) |decl| {
            const info = @typeInfo(decl);
            for (info.Struct.fields) |field| {
                fields[i] = .{
                    .name = field.name,
                    .field_type = Uniform(field.field_type),
                    .default_value = null,
                    .is_comptime = false,
                    .alignment = @alignOf(Uniform(field.field_type)),
                };
                i += 1;
            }
        }
        return @Type(.{
            .Struct = .{
                .layout = .Auto,
                .fields = &fields,
                .decls = &[_]TypeId.Declaration {},
                .is_tuple = false,
            }
        });
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
                    info.kind = .vector;
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

};