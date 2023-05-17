load("//flex/internal:toolchain_alias.bzl", "flex_toolchain_alias")

filegroup(
    name = "bzl_srcs",
    srcs = glob(["*.bzl"]) + [
        "//flex/extensions:bzl_srcs",
        "//flex/internal:bzl_srcs",
        "//flex/rules:bzl_srcs",
    ],
    visibility = ["//:__subpackages__"],
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

flex_toolchain_alias(
    name = "current_flex_toolchain",
    visibility = ["//visibility:public"],
)
