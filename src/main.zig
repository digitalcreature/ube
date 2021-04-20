const std = @import("std");
const builtin = @import("builtin");
const panic = std.debug.panic;

const gl = @import("ube/gl/gl.zig");
usingnamespace gl.c;
usingnamespace @import("ube/math/vector.zig");
const color = @import("ube/math/color.zig");

const foo = gl;
// settings
const SCR_WIDTH: u32 = 1920;
const SCR_HEIGHT: u32 = 1080;

const vertexShaderSource: [:0]const u8 =
    \\#version 460 core
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
    \\#version 460 core
    \\in vec3 color;
    \\out vec4 FragColor;
    \\void main()
    \\{
    \\   FragColor = vec4(color.x, color.y, color.z, 1.0f);
    \\};
;

const Vertex = extern struct {
    position : V3f,
    color : V3f,
};

fn vertex(pos : V3f, col : V3f) Vertex {
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

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    // glfw: initialize and configure
    var window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "Learn OpenGL", null, null);
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
        some_uniform : gl.Uniform([1]V3f),
    }).init();
    defer shaderProgram.deinit();
    shaderProgram.attach(vertexShader);
    shaderProgram.attach(fragShader);
    try shaderProgram.link();
    vertexShader.deinit();
    fragShader.deinit();



    shaderProgram.use();
    const some_uniform : [1]V3f = .{
        v3f(1, 1, 0),
    };
    shaderProgram.uniforms.some_uniform.set(&some_uniform);

    var vertices = [_]Vertex{
        vertex(v3f(0.5, 0.5, 0.0), v3f(1, 0, 1)), // top right
        vertex(v3f(0.5, -0.5, 0.0), v3f(0, 1, 0)), // bottom right
        vertex(v3f(-0.5, -0.5, 0.0), v3f(1, 1, 0)), // bottom let
        vertex(v3f(-0.5, 0.5, 0.0), v3f(0, 1, 1)), // top left
    };
    var indices = [_]u32{ // note that we start from 0!
        0, 1, 3, // first Triangle
        1, 2, 3, // second Triangle
    };
    var VAO = gl.VertexArray.init();
    defer VAO.deinit();
    var VBO = gl.Buffer(.Array).init();
    defer VBO.deinit();
    var EBO = gl.Buffer(.ElementArray).init();
    defer EBO.deinit();
    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    VAO.bind();

    VBO.bind();
    VBO.data(&vertices, .StaticDraw);

    EBO.bind();
    EBO.data(&indices, .StaticDraw);


    VAO.attrib_pointers(Vertex, 0);

    // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
    VBO.unbind();

    // remember: do NOT unbind the EBO while a VAO is active as the bound element buffer object IS stored in the VAO; keep the EBO bound.
    // EBO.unbind();

    // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    VAO.unbind();

    var max_texunits : c_int = undefined;
    glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &max_texunits);
    std.log.info("Max texture units: {d}", .{max_texunits});

    // uncomment this call to draw in wireframe polygons.
    //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    // render loop
    // -----------
    while (glfwWindowShouldClose(window) == 0) {
        // input
        processInput(window);
        // render

        // glClearColor(0.2, 0.3, 0.3, 1.0);
        // glClear(GL_COLOR_BUFFER_BIT);

        gl.clear_color(color.rgbf(0.2, 0.3, 0.3));
        gl.clear(.Color);

        // draw our first triangle
        shaderProgram.use();
        VAO.bind();
        // glBindVertexArray(VAO); // seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
        //glDrawArrays(GL_TRIANGLES, 0, 6);
        gl.draw_elements(.Triangles, 6, u32, 0);
        // glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);
        // glBindVertexArray(0); // no need to unbind it every time

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