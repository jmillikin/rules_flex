load("@rules_flex//flex:flex.bzl", "flex_common")
load("@rules_flex//flex/internal:toolchain.bzl", "flex_toolchain_info")

[flex_toolchain_info(
    name = "toolchain_v{}".format(version),
    flex = "@flex_v{}//bin:flex".format(version),
    flex_lexer_h = "@flex_v{}//:flex_lexer_h".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in flex_common.VERSIONS]

cc_binary(
    name = "m4_deny_shell",
    srcs = ["m4_deny_shell.c"],
    visibility = ["//visibility:public"],
)
