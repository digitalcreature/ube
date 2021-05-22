const std = @import("std");
const imgui = @import("imgui.zig");
usingnamespace @import("c");
// const glfw = @import("include/zig");

const GLFW_HAS_WINDOW_TOPMOST = (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3200); // 3.2+ GLFW_FLOATING
const GLFW_HAS_WINDOW_HOVERED = (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3300); // 3.3+ GLFW_HOVERED
const GLFW_HAS_WINDOW_ALPHA = (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3300); // 3.3+ glfwSetWindowOpacity
const GLFW_HAS_PER_MONITOR_DPI = (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3300); // 3.3+ glfwGetMonitorContentScale
const GLFW_HAS_VULKAN = (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3200); // 3.2+ glfwCreateWindowSurface
// const GLFW_HAS_NEW_CURSORS = @hasDecl(glfw, "GLFW_RESIZE_NESW_CURSOR") and (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3400); // 3.4+ GLFW_RESIZE_ALL_CURSOR, GLFW_RESIZE_NESW_CURSOR, GLFW_RESIZE_NWSE_CURSOR, GLFW_NOT_ALLOWED_CURSOR

const FLT_MAX = std.math.f32_max;

const GlfwClientApi = enum {
    Unknown,
    OpenGL,
    Vulkan,
};

var g_Window: ?*GLFWwindow = null;
var g_ClientApi = GlfwClientApi.Unknown;
var g_Time: f64 = 0.0;
var g_MouseJustPressed = [_]bool{ false, false, false, false, false };
var g_MouseCursors = [_]?*GLFWcursor{null} ** imgui.MouseCursor.COUNT;
var g_InstalledCallbacks = false;

// Chain GLFW callbacks: our callbacks will call the user's previously installed callbacks, if any.
var g_PrevUserCallbackMousebutton: GLFWmousebuttonfun = null;
var g_PrevUserCallbackScroll: GLFWscrollfun = null;
var g_PrevUserCallbackKey: GLFWkeyfun = null;
var g_PrevUserCallbackChar: GLFWcharfun = null;

pub fn InitForOpenGL(window: *GLFWwindow, install_callbacks: bool) bool {
    return Init(window, install_callbacks, .OpenGL);
}

// pub fn InitForVulkan(window: *GLFWwindow, install_callbacks: bool) bool {
//     return Init(window, install_callbacks, .Vulkan);
// }

pub fn Shutdown() void {
    if (g_InstalledCallbacks) {
        _ = glfwSetMouseButtonCallback(g_Window, g_PrevUserCallbackMousebutton);
        _ = glfwSetScrollCallback(g_Window, g_PrevUserCallbackScroll);
        _ = glfwSetKeyCallback(g_Window, g_PrevUserCallbackKey);
        _ = glfwSetCharCallback(g_Window, g_PrevUserCallbackChar);
        g_InstalledCallbacks = false;
    }

    for (g_MouseCursors) |*cursor| {
        glfwDestroyCursor(cursor.*);
        cursor.* = null;
    }
    g_ClientApi = .Unknown;
}

pub fn NewFrame() void {
    const io = imgui.GetIO();
    // "Font atlas not built! It is generally built by the renderer back-end. Missing call to renderer _NewFrame() function? e.g. ImGui_ImplOpenGL3_NewFrame()."
    std.debug.assert(io.Fonts.?.IsBuilt());

    // Setup display size (every frame to accommodate for window resizing)
    var w: c_int = undefined;
    var h: c_int = undefined;
    var display_w: c_int = undefined;
    var display_h: c_int = undefined;
    glfwGetWindowSize(g_Window, &w, &h);
    glfwGetFramebufferSize(g_Window, &display_w, &display_h);
    io.DisplaySize = imgui.Vec2{ .x = @intToFloat(f32, w), .y = @intToFloat(f32, h) };
    if (w > 0 and h > 0)
        io.DisplayFramebufferScale = imgui.Vec2{ .x = @intToFloat(f32, display_w) / @intToFloat(f32, w), .y = @intToFloat(f32, display_h) / @intToFloat(f32, h) };

    // Setup time step
    const current_time = glfwGetTime();
    io.DeltaTime = if (g_Time > 0.0) @floatCast(f32, current_time - g_Time) else @floatCast(f32, 1.0 / 60.0);
    g_Time = current_time;

    UpdateMousePosAndButtons();
    UpdateMouseCursor();

    // Update game controllers (if enabled and available)
    UpdateGamepads();
}

fn Init(window: *GLFWwindow, install_callbacks: bool, client_api: GlfwClientApi) bool {
    g_Window = window;
    g_Time = 0.0;

    // Setup back-end capabilities flags
    var io = imgui.GetIO();
    io.BackendFlags.HasMouseCursors = true; // We can honor GetMouseCursor() values (optional)
    io.BackendFlags.HasSetMousePos = true; // We can honor io.WantSetMousePos requests (optional, rarely used)
    io.BackendPlatformName = "imgui_impl_glfw";

    // Keyboard mapping. ImGui will use those indices to peek into the io.KeysDown[] array.
    io.KeyMap[@enumToInt(imgui.Key.Tab)] = GLFW_KEY_TAB;
    io.KeyMap[@enumToInt(imgui.Key.LeftArrow)] = GLFW_KEY_LEFT;
    io.KeyMap[@enumToInt(imgui.Key.RightArrow)] = GLFW_KEY_RIGHT;
    io.KeyMap[@enumToInt(imgui.Key.UpArrow)] = GLFW_KEY_UP;
    io.KeyMap[@enumToInt(imgui.Key.DownArrow)] = GLFW_KEY_DOWN;
    io.KeyMap[@enumToInt(imgui.Key.PageUp)] = GLFW_KEY_PAGE_UP;
    io.KeyMap[@enumToInt(imgui.Key.PageDown)] = GLFW_KEY_PAGE_DOWN;
    io.KeyMap[@enumToInt(imgui.Key.Home)] = GLFW_KEY_HOME;
    io.KeyMap[@enumToInt(imgui.Key.End)] = GLFW_KEY_END;
    io.KeyMap[@enumToInt(imgui.Key.Insert)] = GLFW_KEY_INSERT;
    io.KeyMap[@enumToInt(imgui.Key.Delete)] = GLFW_KEY_DELETE;
    io.KeyMap[@enumToInt(imgui.Key.Backspace)] = GLFW_KEY_BACKSPACE;
    io.KeyMap[@enumToInt(imgui.Key.Space)] = GLFW_KEY_SPACE;
    io.KeyMap[@enumToInt(imgui.Key.Enter)] = GLFW_KEY_ENTER;
    io.KeyMap[@enumToInt(imgui.Key.Escape)] = GLFW_KEY_ESCAPE;
    io.KeyMap[@enumToInt(imgui.Key.KeyPadEnter)] = GLFW_KEY_KP_ENTER;
    io.KeyMap[@enumToInt(imgui.Key.A)] = GLFW_KEY_A;
    io.KeyMap[@enumToInt(imgui.Key.C)] = GLFW_KEY_C;
    io.KeyMap[@enumToInt(imgui.Key.V)] = GLFW_KEY_V;
    io.KeyMap[@enumToInt(imgui.Key.X)] = GLFW_KEY_X;
    io.KeyMap[@enumToInt(imgui.Key.Y)] = GLFW_KEY_Y;
    io.KeyMap[@enumToInt(imgui.Key.Z)] = GLFW_KEY_Z;

    io.SetClipboardTextFn = @ptrCast(@TypeOf(io.SetClipboardTextFn), SetClipboardText);
    io.GetClipboardTextFn = @ptrCast(@TypeOf(io.GetClipboardTextFn), GetClipboardText);
    io.ClipboardUserData = g_Window;
    // if (std.builtin.os.tag == .windows) {
    //     io.ImeWindowHandle = glfwGetWin32Window(g_Window);
    // }

    // Create mouse cursors
    // (By design, on X11 cursors are user configurable and some cursors may be missing. When a cursor doesn't exist,
    // GLFW will emit an error which will often be printed by the app, so we temporarily disable error reporting.
    // Missing cursors will return NULL and our _UpdateMouseCursor() function will use the Arrow cursor instead.)
    const prev_error_callback = glfwSetErrorCallback(null);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.Arrow)] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.TextInput)] = glfwCreateStandardCursor(GLFW_IBEAM_CURSOR);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNS)] = glfwCreateStandardCursor(GLFW_VRESIZE_CURSOR);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeEW)] = glfwCreateStandardCursor(GLFW_HRESIZE_CURSOR);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.Hand)] = glfwCreateStandardCursor(GLFW_HAND_CURSOR);
    // if (GLFW_HAS_NEW_CURSORS) {
    //     g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeAll)] = glfwCreateStandardCursor(GLFW_RESIZE_ALL_CURSOR);
    //     g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNESW)] = glfwCreateStandardCursor(GLFW_RESIZE_NESW_CURSOR);
    //     g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNWSE)] = glfwCreateStandardCursor(GLFW_RESIZE_NWSE_CURSOR);
    //     g_MouseCursors[@enumToInt(imgui.MouseCursor.NotAllowed)] = glfwCreateStandardCursor(GLFW_NOT_ALLOWED_CURSOR);
    // } else {
    g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeAll)] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNESW)] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNWSE)] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.NotAllowed)] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
    // }
    _ = glfwSetErrorCallback(prev_error_callback);

    // Chain GLFW callbacks: our callbacks will call the user's previously installed callbacks, if any.
    g_PrevUserCallbackMousebutton = null;
    g_PrevUserCallbackScroll = null;
    g_PrevUserCallbackKey = null;
    g_PrevUserCallbackChar = null;
    if (install_callbacks) {
        g_InstalledCallbacks = true;
        g_PrevUserCallbackMousebutton = glfwSetMouseButtonCallback(window, MouseButtonCallback);
        g_PrevUserCallbackScroll = glfwSetScrollCallback(window, ScrollCallback);
        g_PrevUserCallbackKey = glfwSetKeyCallback(window, KeyCallback);
        g_PrevUserCallbackChar = glfwSetCharCallback(window, CharCallback);
    }

    g_ClientApi = client_api;
    return true;
}

fn UpdateMousePosAndButtons() void {
    // Update buttons
    var io = imgui.GetIO();
    for (io.MouseDown) |*down, i| {
        // If a mouse press event came, always pass it as "mouse held this frame", so we don't miss click-release events that are shorter than 1 frame.
        down.* = g_MouseJustPressed[i] or glfwGetMouseButton(g_Window, @intCast(c_int, i)) != 0;
        g_MouseJustPressed[i] = false;
    }

    // Update mouse position
    const mouse_pos_backup = io.MousePos;
    io.MousePos = imgui.Vec2{ .x = -FLT_MAX, .y = -FLT_MAX };
    const focused = glfwGetWindowAttrib(g_Window, GLFW_FOCUSED) != 0;
    if (focused) {
        if (io.WantSetMousePos) {
            glfwSetCursorPos(g_Window, @floatCast(f64, mouse_pos_backup.x), @floatCast(f64, mouse_pos_backup.y));
        } else {
            var mouse_x: f64 = undefined;
            var mouse_y: f64 = undefined;
            glfwGetCursorPos(g_Window, &mouse_x, &mouse_y);
            io.MousePos = imgui.Vec2{ .x = @floatCast(f32, mouse_x), .y = @floatCast(f32, mouse_y) };
        }
    }
}

fn UpdateMouseCursor() void {
    const io = imgui.GetIO();
    if (io.ConfigFlags.NoMouseCursorChange or glfwGetInputMode(g_Window, GLFW_CURSOR) == GLFW_CURSOR_DISABLED)
        return;

    var imgui_cursor = imgui.GetMouseCursor();
    if (imgui_cursor == .None or io.MouseDrawCursor) {
        // Hide OS mouse cursor if imgui is drawing it or if it wants no cursor
        glfwSetInputMode(g_Window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
    } else {
        // Show OS mouse cursor
        // FIXME-PLATFORM: Unfocused windows seems to fail changing the mouse cursor with GLFW 3.2, but 3.3 works here.
        glfwSetCursor(g_Window, if (g_MouseCursors[@intCast(u32, @enumToInt(imgui_cursor))]) |cursor| cursor else g_MouseCursors[@intCast(u32, @enumToInt(imgui.MouseCursor.Arrow))]);
        glfwSetInputMode(g_Window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
    }
}

fn MAP_BUTTON(io: *imgui.IO, buttons: []const u8, NAV_NO: imgui.NavInput, BUTTON_NO: u32) void {
    if (buttons.len > BUTTON_NO and buttons[BUTTON_NO] == GLFW_PRESS)
        io.NavInputs[@intCast(u32, @enumToInt(NAV_NO))] = 1.0;
}

fn MAP_ANALOG(io: *imgui.IO, axes: []const f32, NAV_NO: imgui.NavInput, AXIS_NO: u32, V0: f32, V1: f32) void {
    var v = if (axes.len > AXIS_NO) axes[AXIS_NO] else V0;
    v = (v - V0) / (V1 - V0);
    if (v > 1.0) v = 1.0;
    if (io.NavInputs[@intCast(u32, @enumToInt(NAV_NO))] < v)
        io.NavInputs[@intCast(u32, @enumToInt(NAV_NO))] = v;
}

fn UpdateGamepads() void {
    const io = imgui.GetIO();
    std.mem.set(f32, &io.NavInputs, 0);
    if (!io.ConfigFlags.NavEnableGamepad)
        return;

    // Update gamepad inputs
    var axes_count: c_int = 0;
    var buttons_count: c_int = 0;
    const axesRaw = glfwGetJoystickAxes(GLFW_JOYSTICK_1, &axes_count);
    const buttonsRaw = glfwGetJoystickButtons(GLFW_JOYSTICK_1, &buttons_count);
    const axes = axesRaw.?[0..@intCast(u32, axes_count)];
    const buttons = buttonsRaw.?[0..@intCast(u32, buttons_count)];
    MAP_BUTTON(io, buttons, .Activate, 0); // Cross / A
    MAP_BUTTON(io, buttons, .Cancel, 1); // Circle / B
    MAP_BUTTON(io, buttons, .Menu, 2); // Square / X
    MAP_BUTTON(io, buttons, .Input, 3); // Triangle / Y
    MAP_BUTTON(io, buttons, .DpadLeft, 13); // D-Pad Left
    MAP_BUTTON(io, buttons, .DpadRight, 11); // D-Pad Right
    MAP_BUTTON(io, buttons, .DpadUp, 10); // D-Pad Up
    MAP_BUTTON(io, buttons, .DpadDown, 12); // D-Pad Down
    MAP_BUTTON(io, buttons, .FocusPrev, 4); // L1 / LB
    MAP_BUTTON(io, buttons, .FocusNext, 5); // R1 / RB
    MAP_BUTTON(io, buttons, .TweakSlow, 4); // L1 / LB
    MAP_BUTTON(io, buttons, .TweakFast, 5); // R1 / RB
    MAP_ANALOG(io, axes, .LStickLeft, 0, -0.3, -0.9);
    MAP_ANALOG(io, axes, .LStickRight, 0, 0.3, 0.9);
    MAP_ANALOG(io, axes, .LStickUp, 1, 0.3, 0.9);
    MAP_ANALOG(io, axes, .LStickDown, 1, -0.3, -0.9);
    io.BackendFlags.HasGamepad = axes_count > 0 and buttons_count > 0;
}

fn GetClipboardText(user_data: ?*c_void) callconv(.C) ?[*:0]const u8 {
    return glfwGetClipboardString(@ptrCast(?*GLFWwindow, user_data));
}

fn SetClipboardText(user_data: ?*c_void, text: ?[*:0]const u8) callconv(.C) void {
    glfwSetClipboardString(@ptrCast(?*GLFWwindow, user_data), text);
}

fn MouseButtonCallback(window: ?*GLFWwindow, button: c_int, action: c_int, mods: c_int) callconv(.C) void {
    if (g_PrevUserCallbackMousebutton) |fnPtr| {
        fnPtr(window, button, action, mods);
    }

    if (action == GLFW_PRESS and button >= 0 and @intCast(usize, button) < g_MouseJustPressed.len)
        g_MouseJustPressed[@intCast(usize, button)] = true;
}

fn ScrollCallback(window: ?*GLFWwindow, xoffset: f64, yoffset: f64) callconv(.C) void {
    if (g_PrevUserCallbackScroll) |fnPtr| {
        fnPtr(window, xoffset, yoffset);
    }

    const io = imgui.GetIO();
    io.MouseWheelH += @floatCast(f32, xoffset);
    io.MouseWheel += @floatCast(f32, yoffset);
}

fn KeyCallback(window: ?*GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.C) void {
    if (g_PrevUserCallbackKey) |fnPtr| {
        fnPtr(window, key, scancode, action, mods);
    }

    const io = imgui.GetIO();
    if (action == GLFW_PRESS)
        io.KeysDown[@intCast(usize, key)] = true;
    if (action == GLFW_RELEASE)
        io.KeysDown[@intCast(usize, key)] = false;

    // Modifiers are not reliable across systems
    io.KeyCtrl = io.KeysDown[GLFW_KEY_LEFT_CONTROL] or io.KeysDown[GLFW_KEY_RIGHT_CONTROL];
    io.KeyShift = io.KeysDown[GLFW_KEY_LEFT_SHIFT] or io.KeysDown[GLFW_KEY_RIGHT_SHIFT];
    io.KeyAlt = io.KeysDown[GLFW_KEY_LEFT_ALT] or io.KeysDown[GLFW_KEY_RIGHT_ALT];
    if (std.builtin.os.tag == .windows) {
        io.KeySuper = false;
    } else {
        io.KeySuper = io.KeysDown[GLFW_KEY_LEFT_SUPER] or io.KeysDown[GLFW_KEY_RIGHT_SUPER];
    }
}

fn CharCallback(window: ?*GLFWwindow, c: c_uint) callconv(.C) void {
    if (g_PrevUserCallbackChar) |fnPtr| {
        fnPtr(window, c);
    }

    var io = imgui.GetIO();
    io.AddInputCharacter(c);
}
