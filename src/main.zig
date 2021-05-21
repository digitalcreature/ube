const std = @import("std");
const builtin = @import("builtin");
const panic = std.debug.panic;

usingnamespace @import("c");

const gl = @import("gl");
const glfw = @import("glfw");
const math = @import("math");
usingnamespace math.glm;
const img = @import("zigimg");
const imgui = @import("imgui");
const shaders = @import("shaders");
const voxel = @import("voxel");
const DebugHud = @import("debughud").DebugHud;

pub const log_level = std.log.Level.info;

pub const voxel_config: voxel.Config = .{
    .voxel_size = 0.5,
    .chunk_width = 64,
};

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
    glTextureParameteri(tex.handle, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTextureParameteri(tex.handle, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    return tex;
}

pub fn main() !void {

    glfw.init();
    defer glfw.deinit();

    var window = glfw.Window.init(1920, 1080, "ube");
    defer window.deinit();

    const mouse = &window.mouse;
    mouse.setRawInputMode(.enabled);
    
    const keyboard = &window.keyboard;
    
    window.setVsyncMode(.enabled);

    window.setFrameBufferSizeCallback(framebuffer_size_callback);


    // glfwSetInputMode(window.handle, GLFW_STICKY_KEYS, GLFW_TRUE);

    // glad: load all OpenGL function pointers
    if (gladLoadGLLoader(@ptrCast(GLADloadproc, glfwGetProcAddress)) == 0) {
        panic("Failed to initialise GLAD\n", .{});
    }
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_MULTISAMPLE);
    glEnable(GL_CULL_FACE);
    
    imgui.init(&window);
    defer imgui.deinit();

    const grass = loadTexturePng("grass.png");
    defer grass.deinit();
    grass.bindUnit(0);

    const shaders_ = try shaders.loadShaders();

    const voxel_shader = shaders_.voxels;

    voxel_shader.uniforms.voxel_size.set(voxel_config.voxel_size);
    voxel_shader.uniforms.light_dir.set(vec3(1, 2, 3).normalize());
    voxel_shader.uniforms.proj.set(Mat4.createPerspective(1.5708, 16.0 / 9.0, 0.1, 1000));
    voxel_shader.uniforms.view.set(Mat4.createLookAt(vec3(0, 0, -24), Vec3.zero, Vec3.unit("y")));
    voxel_shader.uniforms.albedo.set(0);

    // voxel stuffs
    var voxel_vao = voxel.ChunkMesh.initVAO();
    defer voxel_vao.deinit();

    // voxel chunk
    var chunk = voxel.Chunk.init();
    for (chunk.voxels.data) |*yz_slice, x| {
        for (yz_slice.*) |*z_slice, y| {
            for (z_slice.*) |*v, z| {
                const pos = autoVec(.{x, y, z}).intToFloat(Vec3);
                const noise = math.perlin.noise(pos.scale(0.05));
                v.* = if (noise < 0.25) 0 else 1;
            }
        }
    }

    // voxel mesh
    var mesh = voxel.ChunkMesh.init(std.heap.c_allocator);
    defer mesh.deinit();
    try mesh.generate(chunk);
    mesh.updateBuffer();

    voxel_vao.vertices.quad_instances.bindBuffer(mesh.vbo);
    voxel_shader.use();
    voxel_vao.bind();

    var debughud = DebugHud.init(&window);
    var look_angles = DVec2.zero;
    while (!window.shouldClose()) {
        window.update();

        if (keyboard.wasKeyPressed(.escape).?) {
            window.setShouldClose(true);
        }

        if (keyboard.wasKeyPressed(.grave).?) {
            debughud.is_visible = !debughud.is_visible;
        }
        
        var mouse_delta = mouse.cursor_position_delta.scale(window.time.frame_time * 5);
        look_angles = look_angles.add(mouse_delta);
        if (look_angles.y > 90) {
            look_angles.y = 90;
        }
        if (look_angles.y < -90) {
            look_angles.y = -90;
        }
        const look_angles_radians = look_angles.scale(std.math.pi / 180.0).floatCast(Vec2);
        voxel_shader.uniforms.model.set(Mat4.createEulerYXZ(-look_angles_radians.y, look_angles_radians.x, 0).invert().?);

        gl.clearColor(math.color.ColorF32.rgb(0.2, 0.3, 0.3));
        gl.clear(.ColorDepth);

        gl.drawElementsInstanced(.Triangles, 6, u32, mesh.quad_instances.items.len);

        imgui.beginFrame();

        // imgui.ShowDemoWindowExt(&show_demo_window);
        debughud.draw();

        imgui.endFrame();

        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        window.swapBuffers();
        // const total_delta_this_frame: f64 = glfwGetTime() - frame_time;
        // // if (total_delta_this_frame == 0) std.log.warn("total_delta_this_frame is zero!", .{});
        // // std.log.info("total_delta_this_frame: {d}", .{total_delta_this_frame});
        // const fps = 1 / total_delta_this_frame;
        // std.log.info("fps: {d}", .{fps});
        // if (fps > max_fps) {
        //     const sleep_time: f64 = (1 / max_fps);// - total_delta_this_frame;
        //     // std.log.info("sleep_time: {d}", .{sleep_time});
        //     std.time.sleep(@floatToInt(u64, sleep_time * std.time.ns_per_s));
        // }
    }
}

// glfw: whenever the window size changed (by OS or user resize) this callback function executes
pub fn framebuffer_size_callback(window: ?glfw.Window.Handle, width: c_int, height: c_int) callconv(.C) void {
    // make sure the viewport matches the new window dimensions; note that width and
    // height will be significantly larger than specified on retina displays.
    glViewport(0, 0, width, height);
}
