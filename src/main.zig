const std = @import("std");
const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const zmath = @import("zmath");
const ShaderProgram = @import("shader.zig").ShaderProgram;
const mesh = @import("mesh.zig");

const width: c_int = 800;
const height: c_int = 600;

const sqrt3: f32 = @sqrt(3.0);
const vertices = [_]f32{ -0.5, -0.5 * sqrt3 / 3.0, 0.0, 0.5, -0.5 * sqrt3 / 3.0, 0.0, 0.0, 0.5 * sqrt3 * 2 / 3.0, 0.0 };

pub fn main() !void {
    // Initialize glfw for window creation and input detection
    try glfw.init();
    defer glfw.terminate();

    // Specifices what version this context uses
    glfw.windowHint(glfw.WindowHint.context_version_major, 3);
    glfw.windowHint(glfw.WindowHint.context_version_minor, 3);
    glfw.windowHint(glfw.WindowHint.opengl_profile, glfw.OpenGLProfile.opengl_core_profile);

    // Create a window and context
    const window = try glfw.Window.create(width, height, "booyah", null, null);
    defer window.destroy();
    // Context keeps track of the state this program is left in when the gpu pauses to computes another program (multitasking)
    glfw.makeContextCurrent(window);

    // Load opengl function pointers for this context
    try zopengl.loadCoreProfile(glfw.getProcAddress, 3, 3);
    const gl = zopengl.bindings;

    // Set viewport to handle resizing of what were currently rendering
    gl.viewport(0, 0, width, height);
    // Set color for gl.clear
    gl.clearColor(0.07, 0.13, 0.17, 1);

    // Create shader program and add shader source code to it, then send compiled program to gpu
    var shader_program = ShaderProgram.create();
    defer shader_program.delete();
    shader_program.addShader(gl.VERTEX_SHADER, "shaders/vertex.vert");
    shader_program.addShader(gl.FRAGMENT_SHADER, "shaders/fragment.frag");
    shader_program.link();

    // Create a VAO containing all data for a single model in the form of buffer objects
    var vao = mesh.VAO.create(gl.TRIANGLES);
    defer vao.delete();
    // Create VBO, holds raw vertex data
    var vbo = vao.genBuffer(gl.ARRAY_BUFFER, vertices[0..], gl.STATIC_DRAW);
    defer vbo.delete();
    // Define value type and how many per vertex
    vbo.addAttrib(&.{3}, &.{gl.FLOAT});

    // Application loop
    while (!window.shouldClose()) {
        // Updates state of inputs and window events
        glfw.pollEvents();

        // Start of render loop, start with blank slate
        gl.clear(gl.COLOR_BUFFER_BIT);

        // Activate shader and draw all VAOs of the same "category"
        shader_program.use();
        vao.bind();
        vao.draw(gl.TRIANGLES);

        // Send finished frame to screen
        window.swapBuffers();
    }
}
