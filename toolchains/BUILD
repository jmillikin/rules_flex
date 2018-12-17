load("//:flex.bzl", "FLEX_VERSIONS", "flex_toolchain")

[flex_toolchain(
    name = "v{}".format(version),
    flex = "@flex_v{}//bin:flex".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in FLEX_VERSIONS]

[toolchain(
    name = "v{}_toolchain".format(version),
    toolchain = ":v{}".format(version),
    toolchain_type = "//flex:toolchain_type",
) for version in FLEX_VERSIONS]
