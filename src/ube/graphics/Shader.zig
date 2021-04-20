const std = @import("std");
const builtin = @import("builtin");
const panic = std.debug.panic;
const Allocator = std.mem.Allocator;

const math = @import("../math/math.zig");
const Mat4 = math.M4x4f;
const Vec3 = math.V3f;

usingnamespace @import("../c.zig");

pub const Shader = struct {
    id: c_uint,

    pub fn init(allocator: *Allocator, vertexSource: []const u8, fragmentSource: []const u8) !Shader {
        // compile shaders
        // vertex shader
        const vertex = glCreateShader(GL_VERTEX_SHADER);
        const vertexSrcPtr: ?[*]const u8 = vertexSource.ptr;
        glShaderSource(vertex, 1, &vertexSrcPtr, null);
        glCompileShader(vertex);
        checkCompileErrors(vertex, "VERTEX");
        // fragment Shader
        const fragment = glCreateShader(GL_FRAGMENT_SHADER);
        const fragmentSrcPtr: ?[*]const u8 = fragmentSource.ptr;
        glShaderSource(fragment, 1, &fragmentSrcPtr, null);
        glCompileShader(fragment);
        checkCompileErrors(fragment, "FRAGMENT");
        // shader Program
        const id = glCreateProgram();
        glAttachShader(id, vertex);
        glAttachShader(id, fragment);
        glLinkProgram(id);
        checkCompileErrors(id, "PROGRAM");
        // delete the shaders as they're linked into our program now and no longer necessary
        glDeleteShader(vertex);
        glDeleteShader(fragment);

        return Shader{ .id = id };
    }

    pub fn use(self: Shader) void {
        glUseProgram(self.id);
    }

    pub fn setBool(self: Shader, name: [:0]const u8, val: bool) void {
        // glUniform1i(glGetUniformLocation(ID, name.c_str()), (int)value);
    }

    pub fn setInt(self: Shader, name: [:0]const u8, val: c_int) void {
        glUniform1i(glGetUniformLocation(self.id, name), val);
    }

    pub fn setFloat(self: Shader, name: [:0]const u8, val: f32) void {
        glUniform1f(glGetUniformLocation(self.id, name), val);
    }

    pub fn setMat4(self: Shader, name: [:0]const u8, val: Mat4) void {
        glUniformMatrix4fv(glGetUniformLocation(self.id, name), 1, GL_FALSE, &val.vals[0][0]);
    }

    pub fn setVec3(self: Shader, name: [:0]const u8, val: Vec3) void {
        glUniform3f(glGetUniformLocation(self.id, name), val.vals[0], val.vals[1], val.vals[2]);
    }

    fn checkCompileErrors(shader: c_uint, errType: []const u8) void {
        var success: c_int = undefined;
        var infoLog: [1024]u8 = undefined;
        if (!std.mem.eql(u8, errType, "PROGRAM")) {
            glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
            if (success == 0) {
                glGetShaderInfoLog(shader, 1024, null, &infoLog);
                panic("ERROR::SHADER::{}::COMPILATION_FAILED\n{}\n", .{ errType, infoLog });
            }
        } else {
            glGetShaderiv(shader, GL_LINK_STATUS, &success);
            if (success == 0) {
                glGetShaderInfoLog(shader, 1024, null, &infoLog);
                panic("ERROR::SHADER::LINKING_FAILED\n{}\n", .{infoLog});
            }
        }
    }
};