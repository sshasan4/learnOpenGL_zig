const std = @import("std");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

pub const VAO = struct {
    id: u32 = undefined,

    pub fn init() VAO {
        var vao: VAO = .{};
        gl.genVertexArrays(1, &vao.id);
        return vao;
    }
    pub fn bind(self: *@This()) void {
        gl.bindVertexArray(self.id);
    }
    pub fn unbind(_: *@This()) void {
        gl.bindVertexArray(0);
    }
    pub fn deinit(self: *@This()) void {
        gl.deleteVertexArrays(1, &self.id);
    }

    pub fn genBuffer(self: *@This(), buffer_type: comptime_int, data: anytype, usage: comptime_int) VBO {
        self.bind();
        defer self.unbind();
        var vbo: VBO = .{
            .VAO_id = self.id,
            .buff_type = buffer_type,
        };
        gl.genBuffers(1, &vbo.id);
        gl.bindBuffer(buffer_type, vbo.id);
        defer gl.bindBuffer(buffer_type, 0);
        gl.bufferData(buffer_type, data.len * @sizeOf(@TypeOf(data[0])), data.ptr, usage);
        return vbo;
    }
};

pub const VBO = struct {
    VAO_id: u32 = undefined,
    id: u32 = undefined,
    buff_type: c_uint,
    index: c_uint = 0,
    stride: c_int = 0,

    pub fn deinit(self: *@This()) void {
        gl.deleteBuffers(1, &self.id);
    }
    pub fn addAttrib(self: *@This(), countArr: []const c_int, attrib_typeArr: []const c_uint) void {
        gl.bindVertexArray(self.VAO_id);
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
    }
};
