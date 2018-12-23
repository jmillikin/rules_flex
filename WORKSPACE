workspace(name = "io_bazel_rules_flex")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "io_bazel_rules_m4",
    commit = "a53a85f0ae868b5b54eccfe685a02282096c18fb",
    remote = "https://github.com/jmillikin/rules_m4",
)

load("@io_bazel_rules_m4//:m4.bzl", "m4_register_toolchains")

m4_register_toolchains()

load("//:flex.bzl", "flex_register_toolchains")

flex_register_toolchains()
