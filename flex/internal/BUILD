filegroup(
    name = "bzl_srcs",
    srcs = glob(["*.bzl"]),
    visibility = ["//:__subpackages__"],
)

cc_binary(
    name = "m4_deny_shell",
    srcs = ["m4_deny_shell.c"],
    visibility = ["//visibility:public"],
)
