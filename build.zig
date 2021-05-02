usingnamespace @import("std").build;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("ube", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addIncludeDir("deps/inc");
    exe.addCSourceFile("deps/src/glad.c", &[_][]const u8{"-std=c99"});
    // exe.addIncludeDir("GLFW/include/GLFW");
    exe.addLibPath("deps/lib");
    b.installBinFile("deps/lib/glfw3.dll", "glfw3.dll");
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("shell32");
    exe.linkSystemLibrary("opengl32");

    const math : Pkg = .{
        .name = "math",
        .path = "src/math/lib.zig",
        .dependencies = null,
    };
    const gl : Pkg = .{
        .name = "gl",
        .path = "src/gl/lib.zig",
        .dependencies = .{math}
    };

    exe.addPackage(math);
    exe.addPackage(gl);

    // exe.addIncludeDir("SDL/include");
    // exe.addLibPath("SDL/lib/x64");
    // b.installBinFile("SDL/lib/x64/SDL2.dll", "SDL2.dll");
    // exe.linkSystemLibrary("SDL2");
    // exe.linkSystemLibrary("GL");
    exe.linkLibC();
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
