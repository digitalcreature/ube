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

const vertexShaderSource: [:0]const u8 =
    \\#version 450 core
    \\layout (location = 0) in vec3 aPos;
    \\layout (location = 1) in vec3 aColor;
    \\uniform vec3 some_uniform;
    \\out vec3 color;
    \\void main()
    \\{
    \\   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\   color = aColor + some_uniform;
    \\};
;
const fragmentShaderSource: [:0]const u8 =
    \\#version 450 core
    \\in vec3 color;
    \\out vec4 FragColor;
    \\void main()
    \\{
    \\   FragColor = vec4(color.x, color.y, color.z, 1.0f);
    \\};
;

const Vertex = extern struct {
    position : Vec3,
    color : Vec3,
};

fn vertex(pos : Vec3, col : Vec3) Vertex {
    return Vertex {
        .position = pos,
        .color = col,
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
    const resizeCallback = glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    // glad: load all OpenGL function pointers
    if (gladLoadGLLoader(@ptrCast(GLADloadproc, glfwGetProcAddress)) == 0) {
        panic("Failed to initialise GLAD\n", .{});
    }

    // build and compile our shader program
    const vertexShader = gl.Shader(.Vertex).init();
    vertexShader.source(vertexShaderSource);
    try vertexShader.compile();
    const fragShader = gl.Shader(.Fragment).init();
    fragShader.source(fragmentShaderSource);
    try fragShader.compile();
    var shaderProgram = gl.Program(struct {
        some_uniform : gl.Uniform([1]Vec3),
    }).init();
    defer shaderProgram.deinit();
    shaderProgram.attach(vertexShader);
    shaderProgram.attach(fragShader);
    try shaderProgram.link();
    vertexShader.deinit();
    fragShader.deinit();



    shaderProgram.use();
    const some_uniform : [1]Vec3 = .{
        vec3(1, 1, 0),
    };
    shaderProgram.uniforms.some_uniform.set(&some_uniform);

    var vertices = [_]Vertex{
        vertex(vec3(0.5, 0.5, 0.0), vec3(1, 0, 1)), // top right
        vertex(vec3(0.5, -0.5, 0.0), vec3(0, 1, 0)), // bottom right
        vertex(vec3(-0.5, -0.5, 0.0), vec3(1, 1, 0)), // bottom let
        vertex(vec3(-0.5, 0.5, 0.0), vec3(0, 1, 1)), // top left
    };
    var indices = [_]u32{ // note that we start from 0!
        0, 1, 3, // first Triangle
        1, 2, 3, // second Triangle
    };
    var vertex_array = gl.VertexArray(struct {
        verts : gl.VertexBufferBind(Vertex, 0, 0)
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
    while (glfwWindowShouldClose(window) == 0) {
        // input
        processInput(window);
        // render


        gl.clearColor(math.color.ColorF32.rgb(0.2, 0.3, 0.3));
        gl.clear(.Color);

        shaderProgram.use();
        vertex_array.bind();
        gl.drawElements(.Triangles, 6, u32);

        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)

        glfwSwapBuffers(window);
        glfwPollEvents();
    }
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
pub fn processInput(window: ?*GLFWwindow) callconv(.C) void {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, 1);
}

// glfw: whenever the window size changed (by OS or user resize) this callback function executes
pub fn framebuffer_size_callback(window: ?*GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    // make sure the viewport matches the new window dimensions; note that width and
    // height will be significantly larger than specified on retina displays.
    glViewport(0, 0, width, height);
}