const std = @import("std");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

pub const VAO = struct {
    id: u32 = undefined,
    mode: c_uint,
    buffer_size: c_int = 0,
    element_count: c_int = 0,

    /// Registers openGL vertex array, returns field `.id`
    pub fn create(drawmode: c_uint) VAO {
        var vao: VAO = .{ .mode = drawmode };
        gl.genVertexArrays(1, &vao.id);
        return vao;
    }
    /// Set this to current VAO
    pub fn bind(self: *@This()) void {
        gl.bindVertexArray(self.id);
    }
    /// Set active VAO to nothing
    pub fn unbind(_: *@This()) void {
        gl.bindVertexArray(0);
    }
    /// Clean up function, deletes from gpu
    pub fn delete(self: *@This()) void {
        gl.deleteVertexArrays(1, &self.id);
    }
    /// Create a buffer object, add it to VAO's table of 'buffer_type'
    pub fn genBuffer(self: *@This(), buffer_type: comptime_int, data: anytype, usage: comptime_int) BufferObj {
        self.bind();
        defer self.unbind();
        var vbo: BufferObj = .{
            .vao = self,
            .buff_type = buffer_type,
        };
        gl.genBuffers(1, &vbo.id);
        gl.bindBuffer(buffer_type, vbo.id);
        defer gl.bindBuffer(buffer_type, 0);
        const buffer_byte_size = data.len * @sizeOf(@TypeOf(data[0]));
        gl.bufferData(buffer_type, buffer_byte_size, data.ptr, usage);
        if (self.buffer_size == 0) {
            self.buffer_size = buffer_byte_size;
        }
        return vbo;
    }
    /// Draw function only draws with drawArrays for now. Uses first buffer size and stride to calculate element count
    pub fn draw(self: *@This(), mode:c_uint) void {
        gl.drawArrays(mode, 0, self.element_count);
    }
};

pub const BufferObj = struct {
    vao: *VAO,
    id: u32 = undefined,
    buff_type: c_uint,
    index: c_uint = 0,
    stride: c_int = 0,

    // Clean up function, deletes from gpu
    pub fn delete(self: *@This()) void {
        gl.deleteBuffers(1, &self.id);
    }

    /// Adds fields to buffer object. Use function only once or else you mess up stride
    pub fn addAttrib(self: *@This(), countArr: []const c_int, attrib_typeArr: []const c_uint) void {
        gl.bindVertexArray(self.vao.id);
        defer gl.bindVertexArray(0);
        gl.bindBuffer(self.buff_type, self.id);
        defer gl.bindBuffer(self.buff_type, 0);

        for (countArr, attrib_typeArr) |count, attrib_type| {
            const size: c_uint = switch (attrib_type) {
                gl.UNSIGNED_INT => @sizeOf(u32),
                gl.INT => @sizeOf(i32),
                gl.FLOAT => @sizeOf(f32),
                gl.DOUBLE => @sizeOf(f64),
                gl.UNSIGNED_BYTE => @sizeOf(u8),
                gl.BYTE => @sizeOf(i8),
                gl.UNSIGNED_SHORT => @sizeOf(u16),
                gl.SHORT => @sizeOf(i16),
                else => unreachable,
            };
            self.stride += count * @as(c_int, @intCast(size));
        }
        for (countArr, attrib_typeArr) |count, attrib_type| {
            gl.vertexAttribPointer(self.index, count, attrib_type, gl.FALSE, self.stride, null);
            gl.enableVertexAttribArray(self.index);
            self.index += 1;
        }
        if (self.vao.element_count == 0) {
            self.vao.element_count = @divExact(self.vao.buffer_size, self.stride);
        }
    }
};
