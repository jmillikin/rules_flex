load("//flex:flex.bzl", "flex_cc_library")

# buildifier: disable=bzl-visibility
load("//flex/internal:versions.bzl", "VERSION_URLS")

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

filegroup(
    name = "testdata",
    srcs = [
        ":genrule_flex_cc",
        ":genrule_test",
        ":hello_c_bin",
        ":hello_cc_bin",
    ],
)

cc_test(
    name = "flex_test",
    srcs = ["flex_test.cc"],
    data = [":testdata"],
    deps = [
        "@bazel_tools//tools/cpp/runfiles",
        "@com_google_googletest//:gtest",
        "@com_google_googletest//:gtest_main",
    ],
)

filegroup(
    name = "all_versions",
    srcs = ["@flex_v{}//bin:flex".format(version) for version in VERSION_URLS],
    tags = ["manual"],
)
