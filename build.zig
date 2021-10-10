// "Works on my machine"
const std = @import("std");
usingnamespace std.build;
const buildres = @import("buildres.zig");

fn addDeps(step: *LibExeObjStep) void {
    // SRC libs

    const math: Pkg = .{
                     .name = "math",
                     .path = "src/math/lib.zig",
    };
    const res: Pkg = .{
                     .name = "res",
                     .path = "res/.zig",
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
                     .dependencies = &[_]Pkg{ math, c, glfw },
    };
    const threading: Pkg = .{
                     .name = "threading",
                     .path = "src/threading/lib.zig",
                     .dependencies = &[_]Pkg{},
    };
    const voxel: Pkg = .{
                     .name = "voxel",
                     .path = "src/voxel/lib.zig",
                     .dependencies = &[_]Pkg{ gl, math, threading, res },
    };
    const camera: Pkg = .{
                     .name = "camera",
                     .path = "src/camera/lib.zig",
                     .dependencies = &[_]Pkg{ imgui, math, glfw },
    };
    const debughud: Pkg = .{
                     .name = "debughud",
                     .path = "src/debughud/lib.zig",
                     .dependencies = &[_]Pkg{ imgui, math, glfw, camera },
    };
    const mesh: Pkg = .{
                     .name = "mesh",
                     .path = "src/mesh/lib.zig",
                     .dependencies = &[_]Pkg{ math, gl },
    };

    //END SRC libs

    // Non-platform specific library

    step.addPackage(math);
    step.addPackage(res);
    step.addPackage(utils);
    step.addPackage(gl);
    step.addPackage(glfw);
    step.addPackage(c);
    step.addPackage(imgui); // h
    step.addPackage(voxel);
    step.addPackage(debughud);
    step.addPackage(camera);
    step.addPackage(threading);
    step.addPackage(mesh);
    //End Non-platform specific library

    // Windows specific libs
    {
                     step.addIncludeDir("deps/inc");
                     // step.addIncludeDir("C:/Users/sam/zig-windows-x86_64-0.8.0/lib/libc/include/any-windows-any");
                     // step.addIncludeDir("C:/Program Files (x86)/Microsoft Visual Studio/2017/Community/VC/Tools/MSVC/14.11.25503/include");
                     step.addCSourceFile("deps/src/glad.c", &[_][]const u8{"-std=c99"});
                     step.addCSourceFile("deps/src/stb_image.c", &[_][]const u8{"-std=c99"});
                     // step.addIncludeDir("GLFW/include/GLFW");

                     step.addLibPath("deps/lib");
                     step.linkSystemLibrary("glfw3");
                     // step.linkSystemLibrary("user32");
                     // step.linkSystemLibrary("gdi32");
                     // step.linkSystemLibrary("shell32");
                     // step.linkSystemLibrary("opengl32");
                     step.linkSystemLibrary("deps/lib/cimguid");

                     // END windows specific libs

                     // Ew libC use reLibC
                     step.linkLibC();
    }
}

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});
    // const target = CrossTarget.

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    b.installBinFile("deps/lib/glfw3.dll", "glfw3.dll");
    const exe = b.addExecutable("wbe", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    addDeps(exe);
    // exe.subsystem = .Linux;
    exe.install();

    // var buildres_step = Step.init(.Custom, "buildres", std.heap.page_allocator, buildResources);
    // exe.step.dependOn(&buildres_step);

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

fn buildResources(step: *Step) !void {
    try buildres.buildResources("res");
}
