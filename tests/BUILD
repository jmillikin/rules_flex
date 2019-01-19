load("@io_bazel_rules_flex//flex:flex.bzl", "flex_lexer")

cc_library(
    name = "hello_common",
    srcs = ["hello_common.c"],
    hdrs = ["hello_common.h"],
)

flex_lexer(
    name = "hello_c",
    src = "hello_c.l",
)

cc_library(
    name = "hello_c_lib",
    srcs = [":hello_c"],
    deps = [":hello_common"],
)

cc_binary(
    name = "hello_c_bin",
    srcs = ["hello_c.c"],
    deps = [":hello_c_lib"],
)

flex_lexer(
    name = "hello_cc",
    src = "hello_cc.ll",
)

cc_library(
    name = "hello_cc_lib",
    srcs = [":hello_cc"],
    deps = [":hello_common"],
)

cc_binary(
    name = "hello_cc_bin",
    srcs = ["hello_cc.cc"],
    deps = [":hello_cc_lib"],
)
