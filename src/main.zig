const std = @import("std");
const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const zmath = @import("zmath");

const width: c_int = 800;
const height: c_int = 600;
pub fn main() !void {
    // initialize glfw for window creation and input detection
    try glfw.init();
    defer glfw.terminate();

    // specifices what version this context uses
    glfw.windowHint(glfw.WindowHint.context_version_major, 3);
    glfw.windowHint(glfw.WindowHint.context_version_minor, 3);
    glfw.windowHint(glfw.WindowHint.opengl_profile, glfw.OpenGLProfile.opengl_core_profile);
    
    //create a window and close at end of program
    const window = try glfw.Window.create(width, height, "booyah", null, null);
    defer window.destroy();
    // context is the state this program is left in when the computer computes another program and returns
    glfw.makeContextCurrent(window);
    
    // load opengl function pointers for this context
    try zopengl.loadCoreProfile(glfw.getProcAddress, 3, 3);
    const gl = zopengl.bindings;
    
    // set viewport to handle resizing of what were currently rendering
    gl.viewport(0, 0, width, height);
    // set color for gl.clear
    gl.clearColor(0.07, 0.13, 0.17, 1);

    // program loop
    while (!window.shouldClose()) {
        // updates state of inputs and window events
        glfw.pollEvents();

        // start of render loop, start with blank slate
        gl.clear(gl.COLOR_BUFFER_BIT);

        // send finished frame to screen
        window.swapBuffers();
    }
}
