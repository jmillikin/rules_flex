workspace(name = "rules_flex")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_m4",
    urls = ["https://github.com/jmillikin/rules_m4/releases/download/v0.2/rules_m4-v0.2.tar.xz"],
    sha256 = "c67fa9891bb19e9e6c1050003ba648d35383b8cb3c9572f397ad24040fb7f0eb",
)

load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")

m4_register_toolchains()

load("@rules_flex//flex:flex.bzl", "flex_register_toolchains")

flex_register_toolchains()
