const std = @import("std");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

pub const ShaderProgram = struct {
    id: c_uint = 0,


    pub fn create() ShaderProgram {
        return .{ .id = gl.createProgram() };
    }
    pub fn addShader(self: *@This(), shader_type: comptime_int, comptime filepath: []const u8) void {
        //create shader object
        const shader = gl.createShader(shader_type);
        //load source code for shader
        const shader_srcs = [_][*c]const u8{
            @embedFile(filepath),
        };
        defer gl.deleteShader(shader);
        gl.shaderSource(shader, shader_srcs.len, &shader_srcs, null);
        gl.compileShader(shader);

        //add shader to program
        gl.attachShader(self.id, shader);
    }
    pub fn link(self: *@This()) void {
        gl.linkProgram(self.id);
    }
    pub fn use(self: *@This()) void {
        gl.useProgram(self.id);
    }
    pub fn delete(self: *@This()) void {
        gl.deleteProgram(self.id);
    }
};
