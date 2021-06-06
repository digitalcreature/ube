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
const Camera = @import("camera").Camera;
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
    
    gl.init();

    const mouse = &window.mouse;
    mouse.setRawInputMode(.enabled);
    
    const keyboard = &window.keyboard;
    
    window.setVsyncMode(.enabled);
    // window.setVsyncMode(.disabled);


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
        var group = try voxel.VolumeThreadGroup(struct {
            
            pub fn generateChunk(chunk: *voxel.Chunk) !void {
                const mesh = try default_allocator.create(voxel.ChunkMesh);
                mesh.* = voxel.ChunkMesh.init(default_allocator);
                chunk.mesh = mesh;
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

        }.generateChunk).init(default_allocator, volume);
        defer group.deinit();
        try group.spawn();
        group.wait();
    }
    var dirty_chunks = try voxel.VolumeChunkQueue.init(default_allocator, volume, volume.chunks.len);
    defer dirty_chunks.deinit();
    {
        const timer = try std.time.Timer.start();
        defer std.log.info("generated {d} chunk meshes in {d}s", .{volume.chunks.len, @intToFloat(f64, timer.read()) / std.time.ns_per_s});
        var group = try voxel.VolumeThreadGroupWithState(*voxel.VolumeChunkQueue, struct {

            pub fn generateChunkMesh(output: *voxel.VolumeChunkQueue, chunk: *voxel.Chunk) !void {
                const mesh = chunk.mesh.?;
                try mesh.generate(chunk.*);
                chunk.mesh = mesh;
                try output.enqueue(chunk);
                // try dirty_chunks.enqueue(chunk);
            }

        }.generateChunkMesh).init(default_allocator, volume, &dirty_chunks);
        defer group.deinit();
        try group.spawn();
        group.wait();
    }
    // chunks.reset();
    var chunks = volume.getChunkIterator();
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

    var camera = Camera.init();
    var debughud = DebugHud.init(&window, &camera);
    
    while (!window.shouldClose()) {
        window.update();

        if (keyboard.wasKeyPressed(.escape).?) {
            window.setShouldClose(true);
        }

        if (keyboard.wasKeyPressed(.grave).?) {
            mouse.setRawInputMode(if (mouse.cursor_mode) .disabled else .enabled);
            mouse.cursor_mode = !mouse.cursor_mode;
        }

        if (keyboard.wasKeyPressed(.f_3).?) {
            debughud.is_visible = !debughud.is_visible;
        }

        if (keyboard.wasKeyPressed(.f_4).?) {
            const display_mode = window.display_mode;
            const new_mode: glfw.Window.DisplayMode = switch(display_mode) {
                .windowed => .borderless,
                .borderless => .windowed,
            };
            window.setDisplayMode(new_mode, .enabled);
        }
        
        // if (!debughud.is_visible) {
        camera.update(&window);
        // }

        voxel_shader.uniforms.proj.set(camera.proj);
        voxel_shader.uniforms.view.set(camera.view);

        gl.clearColor(math.color.ColorF32.rgb(0.2, 0.3, 0.3));
        gl.clear(.ColorDepth);

        chunks.reset();
        while (chunks.next()) |chunk| {
            if (chunk.mesh) |mesh| {
                if (mesh.vbo) |vbo| {
                    voxel_vao.vertices.quad_instances.bindBuffer(vbo);
                    voxel_shader.uniforms.model.set(Mat4.createTranslation(chunk.position.intToFloat(Vec3).scale(voxel.Chunk.edge_distance)));
                    gl.drawElementsInstanced(.Triangles, 6, u32, mesh.quad_instances.items.len);
                }
            }
        }

        imgui.beginFrame();

        // imgui.ShowDemoWindowExt(&show_demo_window);
        debughud.draw();

        imgui.endFrame();

        window.swapBuffers();
    }
}
