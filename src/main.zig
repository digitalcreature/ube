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
const builting = @import("builtin");
const DebugHud = @import("debughud").DebugHud;

pub const log_level = std.log.Level.info;

pub const voxel_config: voxel.Config = .{
    .voxel_size = 0.5,
    .chunk_width = 64,
};

// pub usingnamespace if (builtin.os.tag == .windows) struct {
//     pub export fn WinMain() i32 {
//         if (main()) {
//             return 0;
//         }
//         else |e| {
//             @panic(@errorName(e));
//         }
//     }
// }
// else struct {

// };

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const default_allocator = &gpa.allocator;

pub fn main() !void {

    glfw.init();
    defer glfw.deinit();

    var window = glfw.Window.init(1920, 1080, "ube");
    defer window.deinit();

    const mouse = &window.mouse;
    mouse.setRawInputMode(.enabled);
    
    const keyboard = &window.keyboard;
    
    window.setVsyncMode(.enabled);
    // window.setVsyncMode(.disabled);

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
    voxel_shader.uniforms.model.set(Mat4.identity);

    // voxel stuffs
    var voxel_vao = voxel.ChunkMesh.initVAO();
    defer voxel_vao.deinit();

    // volume
    const volume = try voxel.Volume.init(default_allocator, 4, 4, 4, ivec3(-2, -2, -2));
    defer volume.deinit();

    {
        const timer = try std.time.Timer.start();
        defer std.log.info("generated {d} chunks in {d}s", .{volume.chunks.len, @intToFloat(f64, timer.read()) / std.time.ns_per_s});
        const group = try voxel.VolumeThreadGroup.init(default_allocator, volume, generateChunk);
        group.deinit();
        // group.wait();
    }
    {
        const timer = try std.time.Timer.start();
        defer std.log.info("generated {d} chunk meshes in {d}s", .{volume.chunks.len, @intToFloat(f64, timer.read()) / std.time.ns_per_s});
        const group = try voxel.VolumeThreadGroup.init(default_allocator, volume, generateChunkMesh);
        group.deinit();
        // group.wait();
    }
    var chunks = volume.getChunkIterator();
    // chunks.reset();
    while (chunks.next()) |chunk| {
        if (chunk.mesh) |mesh| {
            mesh.updateBuffer();
        }
    }
    //     var mesh = try default_allocator.create(voxel.ChunkMesh);
    //     mesh.* = voxel.ChunkMesh.init(default_allocator);
    //     try mesh.generate(chunk.*);
    //     mesh.updateBuffer();
    //     chunk.mesh = mesh;
    // }
    

    // // voxel mesh
    // var mesh = voxel.ChunkMesh.init(default_allocator);
    // defer mesh.deinit();
    // try mesh.generate(chunk);
    // mesh.updateBuffer();

    voxel_shader.use();
    voxel_vao.bind();


    var debughud = DebugHud.init(&window);
    var camera = Camera.init();
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
            camera.update(&window);
        }

        voxel_shader.uniforms.proj.set(camera.proj);
        voxel_shader.uniforms.view.set(camera.view);

        gl.clearColor(math.color.ColorF32.rgb(0.2, 0.3, 0.3));
        gl.clear(.ColorDepth);

        chunks.reset();
        while (chunks.next()) |chunk| {
            if (chunk.mesh) |mesh| {
                voxel_vao.vertices.quad_instances.bindBuffer(mesh.vbo);
                voxel_shader.uniforms.model.set(Mat4.createTranslation(chunk.position.intToFloat(Vec3).scale(voxel.Chunk.edge_distance)));
                gl.drawElementsInstanced(.Triangles, 6, u32, mesh.quad_instances.items.len);
            }
        }

        imgui.beginFrame();

        // imgui.ShowDemoWindowExt(&show_demo_window);
        debughud.draw();

        imgui.endFrame();

        window.swapBuffers();
    }
}

const Camera = struct {

    proj: Mat4 = Mat4.identity,
    view: Mat4 = Mat4.identity,
    pos: Vec3 = Vec3.zero,
    look_angles: DVec2 = DVec2.zero,

    const Self = @This();

    pub fn init() Self {
        return .{};
    }

    pub fn update(self: *Self, window: *glfw.Window) void {
        var mouse_delta = window.mouse.cursor_position_delta.scale(window.time.frame_time * 10);
        var look_angles = self.look_angles.add(mouse_delta);
        if (look_angles.y > 90) {
            look_angles.y = 90;
        }
        if (look_angles.y < -90) {
            look_angles.y = -90;
        }
        self.look_angles = look_angles;
        const look_angles_radians = look_angles.scale(std.math.pi / 180.0).floatCast(Vec2);
        const view = Mat4.createEulerZXY(-look_angles_radians.y, -look_angles_radians.x, 0);
        var pos = self.pos;
        const forward = view.transformDirection(Vec3.unit("z"));
        const right = view.transformDirection(Vec3.unit("x"));
        if (window.keyboard.isKeyDown(.w).?) {
            pos = pos.add(forward.scale(5 * @floatCast(f32, window.time.frame_time)));
        }
        if (window.keyboard.isKeyDown(.s).?) {
            pos = pos.add(forward.scale(-5 * @floatCast(f32, window.time.frame_time)));
        }
        if (window.keyboard.isKeyDown(.a).?) {
            pos = pos.add(right.scale(-5 * @floatCast(f32, window.time.frame_time)));
        }
        if (window.keyboard.isKeyDown(.d).?) {
            pos = pos.add(right.scale(5 * @floatCast(f32, window.time.frame_time)));
        }
        if (window.keyboard.isKeyDown(.space).?) {
            pos = pos.add(Vec3.unit("y").scale(5 * @floatCast(f32, window.time.frame_time)));
        }
        if (window.keyboard.isKeyDown(.left_shift).?) {
            pos = pos.add(Vec3.unit("y").scale(-5 * @floatCast(f32, window.time.frame_time)));
        }
        self.pos = pos;
        self.view = (Mat4.createTranslation(pos).invert() orelse Mat4.identity).mul(view);
        const frame_buffer_size = window.getFrameBufferSize();
        const aspect: f32 = @intToFloat(f32, frame_buffer_size.x) / @intToFloat(f32, frame_buffer_size.y);
        self.proj = Mat4.createPerspective(1.5708, aspect, 0.1, 1000);
    }


};

pub fn generateChunk(chunk: *voxel.Chunk) void {
    const offset = chunk.position.intToFloat(Vec3).scale(voxel.Chunk.edge_distance);
    for (chunk.voxels.data) |*yz_slice, x| {
        for (yz_slice.*) |*z_slice, y| {
            for (z_slice.*) |*v, z| {
                const pos1 = autoVec(.{x, y, z}).intToFloat(Vec3).scale(voxel.config.voxel_size);
                const pos2 = autoVec(.{x + 32, y, z}).intToFloat(Vec3).scale(voxel.config.voxel_size);
                const noise1 = math.perlin.noise(pos1.add(offset).scale(0.1));
                const noise2 = math.perlin.noise(pos2.add(offset).scale(0.1));
                const fill: u8 = if (noise2 < 0.1) 1 else 2;
                v.* = if (noise1 < 0.25) 0 else fill;
            }
        }
    }
}

pub fn generateChunkMesh(chunk: *voxel.Chunk) void {
    var mesh = default_allocator.create(voxel.ChunkMesh) catch unreachable;
    mesh.* = voxel.ChunkMesh.init(default_allocator);
    mesh.generate(chunk.*) catch unreachable;
    chunk.mesh = mesh;
}