workspace(name = "io_bazel_rules_flex")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "io_bazel_rules_m4",
    commit = "73f7c0d56eadf8649291d561439470914718bb3d",
    remote = "https://github.com/jmillikin/rules_m4",
)

load("@io_bazel_rules_m4//m4:m4.bzl", "m4_register_toolchains")

m4_register_toolchains()

load("@io_bazel_rules_flex//flex:flex.bzl", "flex_register_toolchains")

flex_register_toolchains()
