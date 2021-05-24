const std = @import("std");
const builtin = @import("builtin");
const panic = std.debug.panic;

// usingnamespace @import("c");

const gl = @import("gl");
const glfw = @import("glfw");
const math = @import("math");
usingnamespace math.glm;
const img = @import("zigimg");
const imgui = @import("imgui");
const voxel = @import("voxel");
const DebugHud = @import("debughud").DebugHud;

pub const log_level = std.log.Level.info;

pub const voxel_config: voxel.Config = .{
    .voxel_size = 0.5,
    .chunk_width = 64,
};

pub fn main() !void {

    glfw.init();
    defer glfw.deinit();

    var window = glfw.Window.init(1920, 1080, "ube");
    defer window.deinit();

    const mouse = &window.mouse;
    mouse.setRawInputMode(.enabled);
    
    const keyboard = &window.keyboard;
    
    window.setVsyncMode(.enabled);

    gl.init();

    imgui.init(&window);
    defer imgui.deinit();

    const atlas = gl.Texture2dArrayRgb8.init(); {
        var grass_data = try gl.TextureData2dRgb8.initPngBytes(@embedFile("grass.png"));
        defer grass_data.deinit();
        var stone_data = try gl.TextureData2dRgb8.initPngBytes(@embedFile("stone.png"));
        defer stone_data.deinit();

        atlas.alloc(32, 32, 2, null);
        atlas.uploadData2d(grass_data, 0, null);
        atlas.uploadData2d(stone_data, 1, null);
    }
    defer atlas.deinit();

    atlas.filter(.nearest, .nearest);
    // atlas.filterMip(.nearest, .nearest, .nearest);
    // atlas.generateMipMaps();
    atlas.bindUnit(1);

    const voxel_shader = try voxel.loadVoxelsShader();
    defer voxel_shader.deinit();

    voxel_shader.uniforms.voxel_size.set(voxel_config.voxel_size);
    voxel_shader.uniforms.light_dir.set(vec3(1, 2, 3).normalize());
    voxel_shader.uniforms.view.set(Mat4.createLookAt(vec3(0, 0, -24), Vec3.zero, Vec3.unit("y")));
    voxel_shader.uniforms.albedo.set(1);

    // voxel stuffs
    var voxel_vao = voxel.ChunkMesh.initVAO();
    defer voxel_vao.deinit();

    // voxel chunk
    var chunk = voxel.Chunk.init();
    for (chunk.voxels.data) |*yz_slice, x| {
        for (yz_slice.*) |*z_slice, y| {
            for (z_slice.*) |*v, z| {
                const pos1 = autoVec(.{x, y, z}).intToFloat(Vec3);
                const pos2 = autoVec(.{x + 32, y, z}).intToFloat(Vec3);
                const noise1 = math.perlin.noise(pos1.scale(0.05));
                const noise2 = math.perlin.noise(pos2.scale(0.05));
                const fill: u8 = if (noise2 < 0) 1 else 2;
                v.* = if (noise1 < 0.25) 0 else fill;
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
            mouse.setRawInputMode(if (debughud.is_visible) .disabled else .enabled);
        }

        if (keyboard.wasKeyPressed(.f_4).?) {
            const display_mode = window.display_mode;
            const new_mode: glfw.Window.DisplayMode = switch(display_mode) {
                .windowed => .borderless,
                .borderless => .windowed,
            };
            window.setDisplayMode(new_mode, .enabled);
        }
        
        if (!debughud.is_visible) {
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
        }

        const frame_buffer_size = window.getFrameBufferSize();
        const aspect: f32 = @intToFloat(f32, frame_buffer_size.x) / @intToFloat(f32, frame_buffer_size.y);
        if (Mat4.createPerspective(1.5708, aspect, 0.1, 1000)) |proj| {
            voxel_shader.uniforms.proj.set(proj);
        }

        gl.clearColor(math.color.ColorF32.rgb(0.2, 0.3, 0.3));
        gl.clear(.ColorDepth);

        gl.drawElementsInstanced(.Triangles, 6, u32, mesh.quad_instances.items.len);

        imgui.beginFrame();

        // imgui.ShowDemoWindowExt(&show_demo_window);
        debughud.draw();

        imgui.endFrame();

        window.swapBuffers();
    }
}
