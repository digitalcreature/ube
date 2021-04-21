usingnamespace @import("types.zig");
usingnamespace @import("c.zig");

const std = @import("std");

pub const ShaderType = enum(c_uint) {
    Vertex = GL_VERTEX_SHADER,
    Geometry = GL_GEOMETRY_SHADER,
    Fragment = GL_FRAGMENT_SHADER,
    // Compute = GL_COMPUTE_SHADER,
    // TessControl = GL_TESS_CONTROL_SHADER,
    // TessEvaluation = GL_TESS_EVALUATION_SHADER,
};

pub fn Shader(comptime shader_type : ShaderType) type {
    return struct {
        handle : Handle,

        const Self = @This();

        pub fn init() Self {
            const handle = glCreateShader(@enumToInt(shader_type));
            return .{.handle = handle };
        }

        pub fn source(self : Self, string : [:0]const u8) void {
            const len = string.len;
            glShaderSource(self.handle, 1, &string.ptr, @ptrCast(* const c_int, &len));
        }

        pub fn compile(self : Self) !void {
            glCompileShader(self.handle);
            // check for shader compile errors
            var success: c_int = undefined;
            var infoLog: [512]u8 = undefined;
            glGetShaderiv(self.handle, GL_COMPILE_STATUS, &success);
            if (success == 0) {
                glGetShaderInfoLog(self.handle, 512, null, &infoLog);
                std.log.err("Failed to compile {s} shader: \n{s}", .{@tagName(shader_type), infoLog});
                return error.ShaderCompileFailure;
            }
        }

        pub fn deinit(self : Self) void {
            glDeleteShader(self.handle);
        }
    };
}

pub fn Program(comptime Uniforms : type) type {
    return struct {
        handle : Handle,
        uniforms : Uniforms = undefined,

        const Self = @This();

        pub fn init() Self {
            return .{.handle = glCreateProgram()};
        }

        pub fn deinit(self : Self) void {
            glDeleteProgram(self.handle);
        }

        pub fn attach(self : Self, shader : anytype) void {
            glAttachShader(self.handle, shader.handle);
        }

        pub fn link(self : *Self) !void {
            glLinkProgram(self.*.handle);
            // check for linking errors
            var success: c_int = undefined;
            var infoLog: [512]u8 = undefined;
            glGetProgramiv(self.*.handle, GL_LINK_STATUS, &success);
            if (success == 0) {
                glGetProgramInfoLog(self.*.handle, 512, null, &infoLog);
                std.log.err("Failed to link shader program: \n{s}", .{infoLog});
                return error.ProgramLinkFailure;
            }
            var uniforms : Uniforms = undefined;
            inline for (@typeInfo(Uniforms).Struct.fields) |field, i| {
                const name = field.name ++ "";
                @field(uniforms, field.name) = field.field_type.init(glGetUniformLocation(self.handle, name));
            }
            self.*.uniforms = uniforms;
        }

        pub fn use(self : Self) void {
            glUseProgram(self.handle);
        }

        pub fn getUniformLocations(self : Self, comptime T : type) T {
            var locs : T = undefined;
            inline for (@typeInfo(T).Struct.fields) |field, i| {
                const name = field.name ++ "";
                @field(locs, field.name) = .{.location = glGetUniformLocation(self.handle, name)};
            }
            return locs;
        }
    };
}

pub const UniformLocation = c_int;

fn UniformMixin(comptime Self : type, comptime T : type) type {
    return switch(@typeInfo(T)) {
        .Array => |Array| struct {
            
            pub const Element = Array.child;
            pub const len = Array.len;

            pub fn set(self : Self, values : *const[len] Element) void {
                const ptr_f = @ptrCast([*c] const f32, values);
                const ptr_i = @ptrCast([*c] const i32, values);
                const ptr_u = @ptrCast([*c] const u32, values);
                switch (@typeInfo(Element)) {
                    .Int => |Int| {
                        if (Int.bits == 32) {
                            switch (Int.signedness) {
                                .signed => {
                                    glUniform1iv(self.location, len, ptr_i);
                                },
                                .unsigned => {
                                    glUniform1uiv(self.location, len, ptr_u);
                                }
                            }
                        }
                    },
                    .Float => |Float| {
                        if (Float.bits == 32) {
                            glUniform1fv(self.location, len, ptr_f);
                        }
                    },
                    .Struct => |Struct| {
                    if (Struct.layout == .Extern) {
                        switch (Element.compound_type) {
                            .Vector => {
                                switch (Element.Component) {
                                    f32 => {
                                        switch (Element.dimensions) {
                                            2 => glUniform2fv(self.location, len, ptr_f),
                                            3 => glUniform3fv(self.location, len, ptr_f),
                                            4 => glUniform4fv(self.location, len, ptr_f),
                                            else => unreachable,
                                        }
                                    },
                                    i32 => {
                                        switch (Element.dimensions) {
                                            2 => glUniform2iv(self.location, len, ptr_i),
                                            3 => glUniform3iv(self.location, len, ptr_i),
                                            4 => glUniform4iv(self.location, len, ptr_i),
                                            else => unreachable,
                                        }
                                    },
                                    u32 => {
                                        switch (Element.dimensions) {
                                            2 => glUniform2uiv(self.location, len, ptr_u),
                                            3 => glUniform3uiv(self.location, len, ptr_u),
                                            4 => glUniform4uiv(self.location, len, ptr_u),
                                            else => unreachable,
                                        }
                                    },
                                    else => unreachable,
                                }
                            },
                            .Matrix => {
                                switch (Element.dimensions) {
                                    2 => glUniformMatrix2fv(self.location, len, 0, ptr_f),
                                    3 => glUniformMatrix3fv(self.location, len, 0, ptr_f),
                                    4 => glUniformMatrix4fv(self.location, len, 0, ptr_f),
                                    else => unreachable,
                                }
                            },
                        }
                    }
                },
                else => unreachable,
                }
            }
        },
        else => struct {
            pub fn set(self : Self, value : T) void {
            switch (@typeInfo(T)) {
                .Int => |Int| {
                    if (Int.bits == 32) {
                        switch (Int.signedness) {
                            .signed => {
                                glUniform1i(self.location, value);
                            },
                            .unsigned => {
                                glUniform1ui(self.location, value);

                            }
                        }
                    }
                },
                .Float => |Float| {
                    if (Float.bits == 32) {
                        glUniform1f(self.location, value);
                    }
                },
                .Struct => |Struct| {
                    if (Struct.layout == .Extern) {
                        switch (T.compound_type) {
                            .Vector => {
                                switch (T.Component) {
                                    f32 => {
                                        switch (T.dimensions) {
                                            2 => glUniform2f(self.location, value.x, value.y),
                                            3 => glUniform3f(self.location, value.x, value.y, value.z),
                                            4 => glUniform4f(self.location, value.x, value.y, value.z, value.w),
                                            else => unreachable,
                                        }
                                    },
                                    i32 => {
                                        switch (T.dimensions) {
                                            2 => glUniform2i(self.location, value.x, value.y),
                                            3 => glUniform3i(self.location, value.x, value.y, value.z),
                                            4 => glUniform4i(self.location, value.x, value.y, value.z, value.w),
                                            else => unreachable,
                                        }
                                    },
                                    u32 => {
                                        switch (T.dimensions) {
                                            2 => glUniform2ui(self.location, value.x, value.y),
                                            3 => glUniform3ui(self.location, value.x, value.y, value.z),
                                            4 => glUniform4ui(self.location, value.x, value.y, value.z, value.w),
                                            else => unreachable,
                                        }
                                    },
                                    else => unreachable,
                                }
                            },
                            .Matrix => {
                                const ptr = @ptrCast([*c]const f32, &value);
                                switch (T.dimensions) {
                                    2 => glUniformMatrix2fv(self.location, 1, 0, ptr),
                                    3 => glUniformMatrix3fv(self.location, 1, 0, ptr),
                                    4 => glUniformMatrix4fv(self.location, 1, 0, ptr),
                                    else => unreachable,
                                }
                            },
                        }
                    }
                },
                else => unreachable,
            }
        }
        },
    };
}

pub fn Uniform(comptime T : type) type {


    return struct {
        location : UniformLocation,
        const Self = @This();
        pub fn init(location : UniformLocation) Self {
            return .{ .location = location};
        }
        pub usingnamespace UniformMixin(Self, T);

        
    };
}