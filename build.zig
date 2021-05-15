usingnamespace @import("std").build;

fn addDeps(step: *LibExeObjStep) void {
    const math: Pkg = .{
        .name = "math",
        .path = "src/math/lib.zig",
        .dependencies = null,
    };
    const c: Pkg = .{
        .name = "c",
        .path = "src/c.zig",
        .dependencies = null,
    };
    const gl: Pkg = .{
        .name = "gl",
        .path = "src/gl/lib.zig",
        .dependencies = &[_]Pkg{math, c},
    };
    const imgui: Pkg = .{
        .name = "imgui",
        .path = "src/imgui/lib.zig",
        .dependencies = &[_]Pkg{math, c},
    };

    step.addPackage(math);
    step.addPackage(gl);
    step.addPackage(c);
    step.addPackage(imgui);

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
