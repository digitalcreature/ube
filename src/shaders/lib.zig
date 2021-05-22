const gl = @import("gl");
const math = @import("math");
usingnamespace gl;
usingnamespace math.glm;

const std = @import("std");

// pub const Shaders = struct {
//     @"test": Program(struct {
//         proj: Uniform(Mat4),
//         view: Uniform(Mat4),
//         model: Uniform(Mat4),
//         albedo: UniformTextureUnit,
//     }),
//     voxels: Program(struct {
//         proj: Uniform(Mat4),
//         view: Uniform(Mat4),
//         model: Uniform(Mat4),
//         voxel_size: Uniform(f32),
//         light_dir: Uniform(Vec3),
//         albedo: UniformTextureUnit,
//     }),
// };

pub fn loadShader(comptime Uniforms : type, comptime name : []const u8) !Program(Uniforms) {
    const vert_source = @embedFile(name ++ ".vert");
    const frag_source = @embedFile(name ++ ".frag");

    const vert_shader = Shader(.Vertex).init();
    defer vert_shader.deinit();
    vert_shader.source(vert_source);
    try vert_shader.compile();

    const frag_shader = Shader(.Fragment).init();
    defer frag_shader.deinit();
    frag_shader.source(frag_source);
    try frag_shader.compile();

    var program = Program(Uniforms).init();    
    program.attach(vert_shader);
    program.attach(frag_shader);
    try program.link();

    return program;
}

// pub fn loadShaders() !Shaders {
//     const fields = @typeInfo(Shaders).Struct.fields;
//     var shaders : Shaders = undefined;
//     inline for (fields) |field| {
//         const Uniforms = getUniformsType(field.field_type);
//         @field(shaders, field.name) = try loadShader(Uniforms, field.name);
//     }
//     return shaders;
// }

// fn getUniformsType(comptime program_type : type) type {
//     comptime {
//         const fields = @typeInfo(program_type).Struct.fields;
//         var Uniforms_opt : ?type = null;
//         inline for (fields) |field| {
//             if (std.mem.eql(u8, field.name, "uniforms")) {
//                 Uniforms_opt = field.field_type;
//             }
//         }
//         if (Uniforms_opt) |Uniforms| {
//             return Uniforms;
//         }
//         else {
//             @compileError("expected shader program type, found " ++ @typeName(program_type));
//         }
//     }
// }