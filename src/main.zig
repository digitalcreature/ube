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
const global_config = @import("config.zig").global_config;

pub const log_level = std.log.Level.info;

pub const voxel_config: voxel.Config = .{
    .voxel_size = global_config.voxel_size,
    .chunk_width = global_config.chunk_width,
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

const VolumeTask = struct {
    frame: @Frame(generateVolume),
    has_returned: bool = false,
    volume: *voxel.Volume,
    err: ?anyerror = null,

    const Self = @This();

    const GenerateGroup = voxel.VolumeThreadGroup(generateChunk);
    const MesherGroup = voxel.VolumeThreadGroupWithState(*voxel.VolumeChunkQueue, generateChunkMesh);


    pub fn init(volume: *voxel.Volume) Self {
        var self = Self{
            .frame = undefined,
            .volume = volume,
        };
        return self;
    }

    pub fn deinit(self: *Self) !void {
        return await self.frame;
    }

    pub fn start(self: *Self) void {
        self.frame = async self.generateVolume();

    }

    pub fn update(self: *Self) !void {
        if (!self.has_returned) {
            resume self.frame;
        }
        else {
            if (self.err) |err| return err;
        }
    }

    fn generateVolume(self: *Self) !void {
        defer self.has_returned = true;
        errdefer |err| self.err = err;
        // errdefer |err| std.log.err("{}", .{err});
        var generate_group = try GenerateGroup.init(default_allocator, self.volume);
        defer generate_group.deinit();
        
        var dirty_chunks = try voxel.VolumeChunkQueue.init(default_allocator, self.volume, self.volume.chunks.len);
        defer dirty_chunks.deinit();

        var mesher_group = try MesherGroup.init(default_allocator, self.volume, &dirty_chunks);
        defer mesher_group.deinit();

        try generate_group.spawn();
        while (!generate_group.isFinished()) {
            suspend {}
        }
        try mesher_group.spawn();
        while (true) {
            while (dirty_chunks.dequeue()) |chunk| {
                if (chunk.mesh) |mesh| {
                    mesh.updateBuffer();
                }
            }
            if (mesher_group.isFinished()) break;
            suspend {}
        }
    }

    fn generateChunk(chunk: *voxel.Chunk) !void {
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

    fn generateChunkMesh(output: *voxel.VolumeChunkQueue, chunk: *voxel.Chunk) !void {
        const mesh = chunk.mesh.?;
        try mesh.generate(chunk.*);
        chunk.mesh = mesh;
        try output.enqueue(chunk);
        // std.time.sleep(1_000_000_000);
    }

};


pub fn main() !void {

    glfw.init();
    defer glfw.deinit();

    var window = glfw.Window.init(global_config.win_width, global_config.win_height, "ube");
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
        var grass_data = try gl.TextureData2dRgb8.initPngBytes(@embedFile("assets/grass.png"));
        defer grass_data.deinit();
        var stone_data = try gl.TextureData2dRgb8.initPngBytes(@embedFile("assets/stone.png"));
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

    var volume_task = VolumeTask.init(volume);
    volume_task.start();

    // var generate_frame = async generateVolume(volume);

    voxel_shader.use();
    voxel_vao.bind();

    var camera = Camera.init();
    var chunks = volume.getChunkIterator();
    var debughud = DebugHud.init(&window, &camera);
    
    while (!window.shouldClose()) {
        window.update();

        if (keyboard.wasKeyPressed(global_config.action_close).?) {
            window.setShouldClose(true);
        }

        if (keyboard.wasKeyPressed(global_config.action_cursor_mode).?) {
            mouse.setRawInputMode(if (mouse.cursor_mode == .disabled) .disabled else .enabled);
        }

        if (keyboard.wasKeyPressed(global_config.action_debughud).?) {
            debughud.is_visible = !debughud.is_visible;
        }

        if (keyboard.wasKeyPressed(global_config.action_fullscreen).?) {
            const display_mode = window.display_mode;
            const new_mode: glfw.Window.DisplayMode = switch(display_mode) {
                .windowed => .borderless,
                .borderless => .windowed,
            };
            window.setDisplayMode(new_mode, .enabled);
        }
        
        camera.update(&window);

        voxel_shader.uniforms.proj.set(camera.proj);
        voxel_shader.uniforms.view.set(camera.view);

        gl.clearColor(math.color.ColorF32.rgb(0.2, 0.3, 0.3));
        gl.clear(.ColorDepth);

        try volume_task.update();

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
