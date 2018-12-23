load("//:flex.bzl", "FLEX_VERSIONS")
load("//flex:toolchain.bzl", "flex_toolchain")

[flex_toolchain(
    name = "v{}".format(version),
    flex = "@flex_v{}//bin:flex".format(version),
    flex_lexer_h = "@flex_v{}//:flex_lexer_h".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in FLEX_VERSIONS]

[toolchain(
    name = "v{}_toolchain".format(version),
    toolchain = ":v{}".format(version),
    toolchain_type = "//flex:toolchain_type",
) for version in FLEX_VERSIONS]
