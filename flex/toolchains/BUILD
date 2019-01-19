load("//flex:flex.bzl", "flex_common")

[toolchain(
    name = "v{}".format(version),
    toolchain = "//flex/internal:toolchain_v{}".format(version),
    toolchain_type = flex_common.TOOLCHAIN_TYPE,
) for version in flex_common.VERSIONS]
