pub usingnamespace @import("imgui.zig");
const impl_glfw = @import("impl_glfw.zig");
const impl_opengl3 = @import("impl_opengl3.zig");
const glfw = @import("glfw");

pub fn init(window: *glfw.Window) void {
    // Setup Dear ImGui context
    CHECKVERSION();
    _ = CreateContext();
    var imgui_io = GetIO();
    imgui_io.IniFilename = null;
    //io.ConfigFlags |= ConfigFlags.NavEnableKeyboard;     // Enable Keyboard Controls
    //io.ConfigFlags |= ConfigFlags.NavEnableGamepad;      // Enable Gamepad Controls

    // Setup Dear ImGui style
    StyleColorsDark();
    // StyleColorsClassic();

    // Setup Platform/Renderer bindings
    _ = impl_glfw.InitForOpenGL(window.handle, true);
    _ = impl_opengl3.Init("#version 450");
}

pub fn deinit() void {
    impl_opengl3.Shutdown();
    impl_glfw.Shutdown();
    DestroyContext();
}

pub fn beginFrame() void {
    impl_opengl3.NewFrame();
    impl_glfw.NewFrame();
    NewFrame();
}

pub fn endFrame() void {
    Render();
    impl_opengl3.RenderDrawData(GetDrawData());
}