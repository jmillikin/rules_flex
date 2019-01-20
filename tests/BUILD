load("@io_bazel_rules_flex//flex:flex.bzl", "flex_cc_library")

cc_library(
    name = "hello_common",
    srcs = ["hello_common.c"],
    hdrs = ["hello_common.h"],
)

genrule(
    name = "genrule_test",
    srcs = ["hello_c.l"],
    outs = ["genrule_output.c"],
    cmd = """
export M4=$(M4)
$(FLEX) --outfile=$@ $(location hello_c.l)
""",
    toolchains = [
        "@io_bazel_rules_flex//flex:toolchain",
        "@io_bazel_rules_m4//m4:toolchain",
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
