const std = @import("std");
const builtin = @import("builtin");
const panic = std.debug.panic;

const gl = @import("gl");
usingnamespace gl.c;
const math = @import("math");
usingnamespace math.glm;

// settings
const SCR_WIDTH: u32 = 1920;
const SCR_HEIGHT: u32 = 1080;

pub const log_level = std.log.Level.info;

const vertexShaderSource: [:0]const u8 =
    \\#version 450 core
    \\layout (location = 0) in vec3 aPos;
    \\layout (location = 1) in vec3 aNormal;
    \\out vec3 color;
    \\uniform mat4 proj;
    \\uniform mat4 view;
    \\uniform mat4 model;
    \\void main()
    \\{
    \\   gl_Position = proj * view * model * vec4(aPos, 1.0);
    \\   color = aNormal;
    \\};
;
const fragmentShaderSource: [:0]const u8 =
    \\#version 450 core
    \\in vec3 color;
    \\out vec4 FragColor;
    \\void main()
    \\{
    \\   FragColor = abs(vec4(color.x, color.y, color.z, 1.0f));
    \\};
;

const Vertex = extern struct {
    position: Vec3,
    normal: Vec3,
};

fn vertex(position: Vec3, normal: Vec3) Vertex {
    return Vertex{
        .position = position,
        .normal = normal,
    };
}

pub fn main() !void {
    const ok = glfwInit();
    if (ok == 0) {
        panic("Failed to initialise GLFW\n", .{});
    }
    defer glfwTerminate();

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 5);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    // glfw: initialize and configure
    var window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "ube", null, null);
    if (window == null) {
        panic("Failed to create GLFW window\n", .{});
    }

    glfwMakeContextCurrent(window);
    glfwSwapInterval(0);
    const resizeCallback = glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    // glad: load all OpenGL function pointers
    if (gladLoadGLLoader(@ptrCast(GLADloadproc, glfwGetProcAddress)) == 0) {
        panic("Failed to initialise GLAD\n", .{});
    }
    glEnable(GL_DEPTH_TEST);

    // build and compile our shader program
    const vertexShader = gl.Shader(.Vertex).init();
    vertexShader.source(vertexShaderSource);
    try vertexShader.compile();
    const fragShader = gl.Shader(.Fragment).init();
    fragShader.source(fragmentShaderSource);
    try fragShader.compile();
    const Uniforms = struct {
        proj: gl.Uniform(Mat4),
        view: gl.Uniform(Mat4),
        model: gl.Uniform(Mat4),
    };
    var shaderProgram = gl.Program(Uniforms).init();
    defer shaderProgram.deinit();
    shaderProgram.attach(vertexShader);
    shaderProgram.attach(fragShader);
    try shaderProgram.link();
    vertexShader.deinit();
    fragShader.deinit();

    shaderProgram.use();
    shaderProgram.uniforms.proj.set(Mat4.createPerspective(1.5708, 16.0 / 9.0, 0.1, 100));
    shaderProgram.uniforms.view.set(Mat4.createLookAt(vec3(1, 1, 1), Vec3.zero, Vec3.unit("y")));

    const vertices =
        cubeFaceVerts(0) ++
        cubeFaceVerts(1) ++
        cubeFaceVerts(2) ++
        cubeFaceVerts(3) ++
        cubeFaceVerts(4) ++
        cubeFaceVerts(5);
    const indices = comptime cubeFaceIndices(6);
    var vertex_array = gl.VertexArray(struct {
        verts: gl.VertexBufferBind(Vertex, 0, 0)
    }, u32).init();
    defer vertex_array.deinit();
    var vertex_buffer = gl.VertexBuffer(Vertex).initData(&vertices, .StaticDraw);
    defer vertex_buffer.deinit();
    var index_buffer = gl.IndexBuffer32.initData(&indices, .StaticDraw);
    defer index_buffer.deinit();

    vertex_array.vertices.verts.bindBuffer(vertex_buffer);
    vertex_array.bindIndexBuffer(index_buffer);
    // vertex_array.attribFormat(0, Vertex, 0);

    // var max_texunits : c_int = undefined;
    // glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &max_texunits);
    // std.log.info("Max texture units: {d}", .{max_texunits});

    // uncomment this call to draw in wireframe polygons.
    //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    // render loop
    // -----------
    var last_frame_time: f64 = 0;
    var delta_time: f64 = 0;
    while (glfwWindowShouldClose(window) == 0) {
        var frame_time: f64 = glfwGetTime();
        // var print_time : bool = std.math.floor(frame_time) != std.math.floor(last_frame_time);
        delta_time = frame_time - last_frame_time;
        last_frame_time = frame_time;
        // if (print_time) {
        //     std.log.info("time: {d} fps: {d}", .{frame_time, 1/delta_time});
        // }
        // input
        if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
            glfwSetWindowShouldClose(window, 1);
        // render

        var model = Mat4.createAxisAngle(Vec3.unit("y"), @floatCast(f32, frame_time));
        shaderProgram.uniforms.model.set(model);

        gl.clearColor(math.color.ColorF32.rgb(0.2, 0.3, 0.3));
        gl.clear(.ColorDepth);

        shaderProgram.use();
        vertex_array.bind();
        gl.drawElements(.Triangles, indices.len, u32);

        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)

        glfwSwapBuffers(window);
        glfwPollEvents();
    }
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
pub fn processInput(window: ?*GLFWwindow) callconv(.C) void {}

// glfw: whenever the window size changed (by OS or user resize) this callback function executes
pub fn framebuffer_size_callback(window: ?*GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    // make sure the viewport matches the new window dimensions; note that width and
    // height will be significantly larger than specified on retina displays.
    glViewport(0, 0, width, height);
}

fn cubeFaceVerts(comptime face_id: u32) [4]Vertex {
    comptime {
        var verts: [4]Vertex = undefined;
        const normal = Vec3.uniti(face_id);
        const axis = face_id % 3;
        const is_neg = face_id >= 3;
        var i = 0;
        inline while (i < 4) : (i += 1) {
            var pos = normal;
            const flip = if (is_neg) 1 else -1;
            pos.setElement((axis + 1) % 3, if (i % 2 == 0) -1 else 1);
            pos.setElement((axis + 2) % 3, flip * if (i < 2) 1 else -1);
            verts[i] = vertex(pos.scale(0.5), normal);
        }
        return verts;
    }
}

fn cubeFaceIndices(comptime face_count: u32) [face_count * 6]u32 {
    comptime {
        var indices: [face_count * 6]u32 = undefined;
        var face = 0;
        inline while (face < face_count) : (face += 1) {
            indices[face * 6 + 0] = face * 4 + 0;
            indices[face * 6 + 1] = face * 4 + 1;
            indices[face * 6 + 2] = face * 4 + 3;
            indices[face * 6 + 3] = face * 4 + 0;
            indices[face * 6 + 4] = face * 4 + 3;
            indices[face * 6 + 5] = face * 4 + 2;
        }
        return indices;
    }
}

test "cubeFaceVerts" {
    std.testing.log_level = .debug;
    const verts = comptime cubeFaceVerts(0);
    inline for (verts) |vert| {
        std.log.info("{d}", .{vert.position});
    }
}

test "cubeFaceIndices" {
    std.testing.log_level = .debug;
    const indices = comptime cubeFaceIndices(6);
    inline for (indices) |index| {
        std.log.info("{d}", .{index});
    }
}
