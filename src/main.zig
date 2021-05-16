const std = @import("std");
const builtin = @import("builtin");
const panic = std.debug.panic;

const gl = @import("gl");
usingnamespace @import("c");
const math = @import("math");
usingnamespace math.glm;
const img = @import("zigimg");
const imgui = @import("imgui");
const shaders = @import("shaders");

// settings
const SCR_WIDTH: u32 = 1920;
const SCR_HEIGHT: u32 = 1080;

pub const log_level = std.log.Level.info;

const Vertex = extern struct {
    position: Vec3,
    normal: Vec3,
    uv: Vec2,
};

fn vertex(position: Vec3, normal: Vec3, uv: Vec2) Vertex {
    return Vertex{
        .position = position,
        .normal = normal,
        .uv = uv,
    };
}

fn loadTexturePng(comptime name: []const u8) gl.Texture2D {
    const bytes: []const u8 = @embedFile(name);
    var width: i32 = undefined;
    var height: i32 = undefined;
    var channels: i32 = undefined;
    var pixels: *u8 = stbi_load_from_memory(bytes.ptr, bytes.len, &width, &height, &channels, 0);
    defer stbi_image_free(pixels);
    var tex = gl.Texture2D.init();
    tex.storage(null, .RGB8, width, height);
    tex.subImage(null, 0, 0, width, height, .rgb, u8, pixels);
    return tex;
}

fn genTexturePerlin(comptime width: u32, comptime height: u32) gl.Texture2D {
    var pixels : [width][height]math.color.ColorU8 = undefined;
    var x : u32 = 0;
    while (x < width) : (x += 1) {
        var y : u32 = 0;
        while (y < height) : (y += 1) {
            var u = @intToFloat(f32, x) * 0.1;
            var v = @intToFloat(f32, y) * 0.1;
            var n = math.perlin.noise2(u, v);
            var n8 = @floatToInt(u8, std.math.clamp((n + 1) / 2, 0, 1) * 255);
            pixels[x][y] = math.color.ColorU8.rgb(n8, n8, n8);
        }
    }
    var tex = gl.Texture2D.init();
    tex.storage(null, .RGBA8, width, height);
    tex.subImage(null, 0, 0, width, height, .rgba, u8, &pixels);
    return tex;
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

    const shaders_ = try shaders.loadShaders();

    const test_shader = shaders_.@"test";

    // test_shader.use();
    test_shader.uniforms.proj.set(Mat4.createPerspective(1.5708, 16.0 / 9.0, 0.1, 100));
    test_shader.uniforms.view.set(Mat4.createLookAt(vec3(1, 1, 1), Vec3.zero, Vec3.unit("y")));

    // create array
    // the arguments to the array type are the bind points for vertex buffers, and the integer type for the index buffer
    var vertex_array = gl.VertexArray(struct {
        verts: gl.VertexBufferBind(Vertex, 0, 0)
    }, u32).init();
    defer vertex_array.deinit();

    // vertex and index data
    const vertices =
        cubeFaceVerts(0) ++
        cubeFaceVerts(1) ++
        cubeFaceVerts(2) ++
        cubeFaceVerts(3) ++
        cubeFaceVerts(4) ++
        cubeFaceVerts(5);
    const indices = comptime cubeFaceIndices(6);

    // vertex and index buffers
    var vertex_buffer = gl.VertexBuffer(Vertex).initData(&vertices, .StaticDraw);
    defer vertex_buffer.deinit();
    var index_buffer = gl.IndexBuffer32.initData(&indices, .StaticDraw);
    defer index_buffer.deinit();

    // bind buffers to the array
    vertex_array.vertices.verts.bindBuffer(vertex_buffer);
    vertex_array.bindIndexBuffer(index_buffer);

    // uncomment this call to draw in wireframe polygons.
    // glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    // load and bind the texture
    // var texture = loadTexturePng("hello_world.png");
    var texture = genTexturePerlin(64, 64);
    glTextureParameteri(texture.handle, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTextureParameteri(texture.handle, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTextureParameteri(texture.handle, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTextureParameteri(texture.handle, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    defer texture.deinit();
    texture.bindUnit(0);
    test_shader.uniforms.albedo.set(0);

    // we dont need to do these before the draw call because these are the only program and array we are using so far!
    test_shader.use();
    vertex_array.bind();

    
    // Setup Dear ImGui context
    imgui.CHECKVERSION();
    _ = imgui.CreateContext();
    defer imgui.DestroyContext();
    var imgui_io = imgui.GetIO();
    imgui_io.IniFilename = null;
    //io.ConfigFlags |= imgui.ConfigFlags.NavEnableKeyboard;     // Enable Keyboard Controls
    //io.ConfigFlags |= imgui.ConfigFlags.NavEnableGamepad;      // Enable Gamepad Controls

    // Setup Dear ImGui style
    imgui.StyleColorsDark();
    // imgui.StyleColorsClassic();

    // Setup Platform/Renderer bindings
    _ = imgui.glfw.InitForOpenGL(window.?, true);
    defer imgui.glfw.Shutdown();
    _ = imgui.opengl3.Init("#version 450");
    defer imgui.opengl3.Shutdown();


    // render loop
    // -----------
    var last_frame_time: f64 = 0;
    var delta_time: f64 = 0;
    var show_demo_window = true;
    var delta_time_display: f64 = 0;
    const fps_poll_rate: f64 = 0.5;
    while (glfwWindowShouldClose(window) == 0) {
        var frame_time: f64 = glfwGetTime();
        delta_time = frame_time - last_frame_time;
        if (std.math.floor(frame_time / fps_poll_rate) != std.math.floor(last_frame_time / fps_poll_rate)) {
            delta_time_display = delta_time;
        }
        last_frame_time = frame_time;
        // input
        if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
            glfwSetWindowShouldClose(window, 1);
        
        glfwPollEvents();

        imgui.opengl3.NewFrame();
        imgui.glfw.NewFrame();
        imgui.NewFrame();

        imguiFpsOverlay(delta_time_display);
        // imgui.ShowDemoWindowExt(&show_demo_window);

        imgui.Render();

        // render
        var model = Mat4.createAxisAngle(Vec3.unit("y"), @floatCast(f32, frame_time));
        test_shader.uniforms.model.set(model);

        gl.clearColor(math.color.ColorF32.rgb(0.2, 0.3, 0.3));
        gl.clear(.ColorDepth);

        gl.drawElements(.Triangles, indices.len, u32);

        imgui.opengl3.RenderDrawData(imgui.GetDrawData());

        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        glfwSwapBuffers(window);
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
            var uv = Vec2.zero;
            uv.x = if (i % 2 != @boolToInt(is_neg)) 0 else 1;
            uv.y = if ((i < 2) != is_neg) 1 else 0;
            const flip = if (is_neg) 1 else -1;
            pos.setElement((axis + 1) % 3, if (i % 2 == 0) -1 else 1);
            pos.setElement((axis + 2) % 3, flip * if (i < 2) 1 else -1);
            verts[i] = vertex(pos.scale(0.5), normal, uv);
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

fn imguiFpsOverlay(frame_time : f64) void {
    const padding : f32 = 16;
    const window_pos = vec2(padding, padding);
    imgui.SetNextWindowPosExt(window_pos, .{ .Always = true }, Vec2.zero);
    const window_flags : imgui.WindowFlags = (imgui.WindowFlags {
        .NoMove = true,
        .NoBackground = true,
        .AlwaysAutoResize = true,
        .NoFocusOnAppearing = true,
    }).with(imgui.WindowFlags.NoDecoration).with(imgui.WindowFlags.NoNav);
    if (imgui.BeginExt("fps overlay", null, window_flags)) {
        defer imgui.End();
        imgui.Text("frame time:\t%fms", frame_time * 1000);
        imgui.Text("fps:\t\t  %f", 1 / frame_time);
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
