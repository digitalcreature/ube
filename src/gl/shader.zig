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

pub fn Program(comptime UniformDecls: [] const type) type {
    return struct {
        handle: Handle,
        uniforms: Uniforms = undefined,
        shaders: Shaders = .{},

        const Shaders = struct {
            vert: ?Shader(.Vertex) = null,
            geom: ?Shader(.Geometry) = null,
            frag: ?Shader(.Fragment) = null,
        };

        pub const Uniforms = createUniformsStructFromDeclarations(UniformDecls);

        const Self = @This();

        pub fn init() Self {
            return .{ 
                .handle = glCreateProgram(),
            };
        }

        pub fn deinit(self: Self) void {
            inline for (@typeInfo(Shaders).Struct.fields) |field| {
                if (@field(self.shaders, field.name)) |shader| {
                    shader.deinit();
                }
            }
            glDeleteProgram(self.handle);
        }

        pub fn attach(self: Self, shader: anytype) void {
            glAttachShader(self.handle, shader.handle);
        }

        pub fn compileAndAttachShaderFromSource(self: *Self, comptime shader_type: ShaderType, source: [:0]const u8) !void {
            const shader = Shader(shader_type).init();
            shader.source(source);
            try shader.compile();
            switch (shader_type) {
                .Vertex => self.shaders.vert = shader,
                .Geometry => self.shaders.geom = shader,
                .Fragment => self.shaders.frag = shader,
            }
            self.attach(shader);
        }

        pub fn buildFromResources(comptime name: []const u8, comptime res: type) !Self {
            var program = init();
            if (@hasDecl(res, name ++ ".vert")) {
                try program.compileAndAttachShaderFromSource(.Vertex, @field(res, name ++ ".vert"));
            }
            if (@hasDecl(res, name ++ ".geom")) {
                try program.compileAndAttachShaderFromSource(.Geometry, @field(res, name ++ ".geom"));
            }
            if (@hasDecl(res, name ++ ".frag")) {
                try program.compileAndAttachShaderFromSource(.Fragment, @field(res, name ++ ".frag"));
            }
            try program.link();
            return program;
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
