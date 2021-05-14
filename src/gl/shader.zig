usingnamespace @import("types.zig");
usingnamespace @import("c");
usingnamespace @import("uniform.zig");

const std = @import("std");

pub const ShaderType = enum(c_uint) {
    Vertex = GL_VERTEX_SHADER,
    Geometry = GL_GEOMETRY_SHADER,
    Fragment = GL_FRAGMENT_SHADER,
    // Compute = GL_COMPUTE_SHADER,
    // TessControl = GL_TESS_CONTROL_SHADER,
    // TessEvaluation = GL_TESS_EVALUATION_SHADER,
};

pub fn Shader(comptime shader_type: ShaderType) type {
    return struct {
        handle: Handle,

        const Self = @This();

        pub fn init() Self {
            const handle = glCreateShader(@enumToInt(shader_type));
            return .{ .handle = handle };
        }

        pub fn source(self: Self, string: [:0]const u8) void {
            const len = string.len;
            glShaderSource(self.handle, 1, &string.ptr, @ptrCast(*const c_int, &len));
        }

        pub fn compile(self: Self) !void {
            glCompileShader(self.handle);
            // check for shader compile errors
            var success: c_int = undefined;
            var infoLog: [512]u8 = undefined;
            glGetShaderiv(self.handle, GL_COMPILE_STATUS, &success);
            if (success == 0) {
                glGetShaderInfoLog(self.handle, 512, null, &infoLog);
                std.log.err("Failed to compile {s} shader: \n{s}", .{ @tagName(shader_type), infoLog });
                return error.ShaderCompileFailure;
            }
        }

        pub fn deinit(self: Self) void {
            glDeleteShader(self.handle);
        }
    };
}

pub fn Program(comptime Uniforms: type) type {
    return struct {
        handle: Handle,
        uniforms: Uniforms = undefined,

        const Self = @This();

        pub fn init() Self {
            return .{ .handle = glCreateProgram() };
        }

        pub fn deinit(self: Self) void {
            glDeleteProgram(self.handle);
        }

        pub fn attach(self: Self, shader: anytype) void {
            glAttachShader(self.handle, shader.handle);
        }

        pub fn link(self: *Self) !void {
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
            self.*.uniforms = initUniforms(self.*.handle, Uniforms);
        }

        pub fn use(self: Self) void {
            glUseProgram(self.handle);
        }
    };
}
