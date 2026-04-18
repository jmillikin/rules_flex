load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_cc//cc:cc_test.bzl", "cc_test")
load("//flex:flex.bzl", "flex", "flex_cc_library")

cc_library(
    name = "hello_common",
    srcs = ["hello_common.c"],
    hdrs = ["hello_common.h"],
)

genrule(
    name = "genrule_test",
    srcs = ["hello_c.l"],
    outs = ["genrule_output.c"],
    cmd = "M4=$(M4) $(FLEX) --outfile=$@ $(location hello_c.l)",
    toolchains = [
        "//flex:current_flex_toolchain",
        "@rules_m4//m4:current_m4_toolchain",
    ],
)

flex_cc_library(
    name = "hello_c",
    src = "hello_c.l",
    deps = [":hello_common"],
)

cc_binary(
    name = "hello_c_bin",
    srcs = ["hello_c.c"],
    deps = [":hello_c"],
)

flex_cc_library(
    name = "hello_cc",
    src = "hello_cc.ll",
    deps = [":hello_common"],
)

cc_binary(
    name = "hello_cc_bin",
    srcs = ["hello_cc.cc"],
    deps = [":hello_cc"],
)

genrule(
    name = "genrule_flex_cc",
    srcs = ["hello_cc.ll"],
    outs = ["genrule_flex_cc.cc"],
    cmd = "M4=$(M4) $(FLEX) --outfile=$@ --c++ $(location hello_cc.ll)",
    toolchains = [
        "//flex:current_flex_toolchain",
        "@rules_m4//m4:current_m4_toolchain",
    ],
)

cc_binary(
    name = "genrule_flex_cc_bin",
    srcs = [
        "genrule_flex_cc.cc",
        "hello_cc.cc",
    ],
    deps = [
        ":hello_common",
        "//flex:current_flex_toolchain",
    ],
)

flex(
    name = "noline_top_c",
    src = "top_c.l",
    flex_options = ["--noline"],
)

flex(
    name = "override_output_src_ext",
    src = "hello_c.l",
    output_src_ext = "cc",
)

filegroup(
    name = "testdata",
    srcs = [
        ":genrule_flex_cc",
        ":genrule_test",
        ":hello_c_bin",
        ":hello_cc_bin",
        ":noline_top_c",
        ":override_output_src_ext",
    ],
)

cc_test(
    name = "flex_test",
    srcs = ["flex_test.cc"],
    data = [":testdata"],
    deps = [
        "@bazel_tools//tools/cpp/runfiles",
        "@googletest//:gtest",
        "@googletest//:gtest_main",
    ],
)

alias(
    name = "all_versions",
    actual = "@rules_flex_testutil//:all_versions",
    tags = ["manual"],
)
