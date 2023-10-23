const std = @import("std");

pub fn build(b: *std.Build) void {
    const x86_build_target: std.zig.CrossTarget = .{
        .cpu_arch = std.Target.Cpu.Arch.x86_64,
        .cpu_model = std.zig.CrossTarget.CpuModel.determined_by_cpu_arch,
        .cpu_features_add = std.Target.Cpu.Feature.Set.empty,
        .cpu_features_sub = std.Target.Cpu.Feature.Set.empty,
        .os_tag = std.Target.Os.Tag.freestanding,
        .os_version_min = null,
        .os_version_max = null,
        .glibc_version = null,
        .abi = null,
        .dynamic_linker = std.Target.DynamicLinker{},
        .ofmt = null
    };

    const target = b.standardTargetOptions(.{
        .default_target=x86_build_target
    });
    _ = target;

    const optimize = b.standardOptimizeOption(.{});
    _ = optimize;

    
}