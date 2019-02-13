workspace(name = "rules_flex")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "rules_m4",
    commit = "2c0e74918536a8d4295c20b126ba2b2604d0bff1",
    remote = "https://github.com/jmillikin/rules_m4",
)

load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")

m4_register_toolchains()

load("@rules_flex//flex:flex.bzl", "flex_register_toolchains")

flex_register_toolchains()
