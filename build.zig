usingnamespace @import("std").build;

fn addDeps(step: *LibExeObjStep) void {
    const math: Pkg = .{
        .name = "math",
        .path = "src/math/lib.zig",
    };
    const utils: Pkg = .{
        .name = "utils",
        .path = "src/utils/lib.zig",
    };
    const c: Pkg = .{
        .name = "c",
        .path = "src/c.zig",
    };
    const gl: Pkg = .{
        .name = "gl",
        .path = "src/gl/lib.zig",
        .dependencies = &[_]Pkg{ math, c },
    };
    const glfw: Pkg = .{
        .name = "glfw",
        .path = "src/glfw/lib.zig",
        .dependencies = &[_]Pkg{ math, c },
    };
    const imgui: Pkg = .{
        .name = "imgui",
        .path = "src/imgui/lib.zig",
        .dependencies = &[_]Pkg{ math, c },
    };
    const input: Pkg = .{
        .name = "input",
        .path = "src/input/lib.zig",
        .dependencies = &[_]Pkg{ math, c },
    };
    const shaders: Pkg = .{
        .name = "shaders",
        .path = "src/shaders/lib.zig",
        .dependencies = &[_]Pkg{ gl, math },
    };
    const voxel: Pkg = .{
        .name = "voxel",
        .path = "src/voxel/lib.zig",
        .dependencies = &[_]Pkg{ gl, math },
    };
    const debughud: Pkg = .{
        .name = "debughud",
        .path = "src/debughud/lib.zig",
        .dependencies = &[_]Pkg{ imgui, math, glfw },
    };

    step.addPackage(math);
    step.addPackage(utils);
    step.addPackage(gl);
    step.addPackage(glfw);
    step.addPackage(c);
    step.addPackage(imgui);
    // step.addPackage(input);
    step.addPackage(shaders);
    step.addPackage(voxel);
    step.addPackage(debughud);

    step.addIncludeDir("deps/inc");
    step.addCSourceFile("deps/src/glad.c", &[_][]const u8{"-std=c99"});
    step.addCSourceFile("deps/src/stb_image.c", &[_][]const u8{"-std=c99"});
    // step.addIncludeDir("GLFW/include/GLFW");
    step.addLibPath("deps/lib");
    step.linkSystemLibrary("glfw3");
    step.linkSystemLibrary("user32");
    step.linkSystemLibrary("gdi32");
    step.linkSystemLibrary("shell32");
    step.linkSystemLibrary("opengl32");
    step.linkSystemLibrary("deps/Zig-ImGui/lib/win/cimguid");
    step.linkLibC();
}

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    b.installBinFile("deps/lib/glfw3.dll", "glfw3.dll");
    const exe = b.addExecutable("ube", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    addDeps(exe);
    exe.install();

    const test_step = b.step("test", "Run library tests.");
    const file = b.addTest("src/main.zig");
    file.setTarget(target);
    file.setBuildMode(mode);
    addDeps(file);

    test_step.dependOn(&file.step);

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}