load("//flex/internal:toolchain_info.bzl", "flex_toolchain_info")
load("//flex/internal:versions.bzl", "VERSION_URLS")

[flex_toolchain_info(
    name = "toolchain_v{}".format(version),
    flex_lexer_h = "@flex_v{}//:flex_lexer_h".format(version),
    flex_tool = "@flex_v{}//bin:flex".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in VERSION_URLS]

cc_binary(
    name = "m4_deny_shell",
    srcs = ["m4_deny_shell.c"],
    visibility = ["//visibility:public"],
)
