workspace(name = "rules_flex")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_m4",
    urls = ["https://github.com/jmillikin/rules_m4/releases/download/v0.1/rules_m4-v0.1.tar.xz"],
    sha256 = "7bb12b8a5a96037ff3d36993a9bb5436c097e8d1287a573d5958b9d054c0a4f7",
)

load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")

m4_register_toolchains()

load("@rules_flex//flex:flex.bzl", "flex_register_toolchains")

flex_register_toolchains()
