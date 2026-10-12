const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("zig-floyd-rivest", .{
        .root_source_file = b.path("src/floyd_rivest.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "zig-floyd-rivest",
        .root_module = module,
        .linkage = .static,
    });
    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_module = module,
    });

    const run_main_tests = b.addRunArtifact(main_tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
