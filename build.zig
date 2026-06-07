const std = @import("std");

pub fn build(b: *std.Build) void {
    //__Compiler Flags__
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    //__MAIN__ (executable module)
    const exe = b.addExecutable(.{
        .name = "main",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        }),
    });

    //__ZGLFW__
    const zglfw = b.dependency("zglfw", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zglfw", zglfw.module("root"));
    if (target.result.os.tag != .emscripten) {
        exe.root_module.linkLibrary(zglfw.artifact("glfw"));
    }

    //__ZOPENGL__
    const zopengl = b.dependency("zopengl", .{});
    exe.root_module.addImport("zopengl", zopengl.module("root"));

    //__ZMATH__
    const zmath = b.dependency("zmath", .{});
    exe.root_module.addImport("zmath", zmath.module("root"));

    b.installArtifact(exe);

    //__ZIG BUILD RUN__
    // creates text keyword: zig build run
    const run_step = b.step("run", "Run the app");
    // creates a step that runs main.exe
    const run_cmd = b.addRunArtifact(exe);
    // links text keyword to the command
    run_step.dependOn(&run_cmd.step);
    // makes running the program depend on the completion of building the program
    run_cmd.step.dependOn(b.getInstallStep());
    // if there are args, add to run step
    if (b.args) |args| run_cmd.addArgs(args);

    //__ZIG BUILD TEST__
    // creates an exe of the tests in main.zig
    const exe_tests = b.addTest(.{ .root_module = exe.root_module });
    // creates a step that runs tests.exe
    const run_exe_tests = b.addRunArtifact(exe_tests);
    // creates text keyword: zig build test
    const test_step = b.step("test", "Run tests");
    // links text keyword to the command
    test_step.dependOn(&run_exe_tests.step);
}
