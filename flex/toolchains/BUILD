load("//flex:toolchain_type.bzl", "FLEX_TOOLCHAIN_TYPE")
load("//flex/internal:versions.bzl", "VERSION_URLS")

[toolchain(
    name = "v{}".format(version),
    toolchain = "//flex/internal:toolchain_v{}".format(version),
    toolchain_type = FLEX_TOOLCHAIN_TYPE,
) for version in VERSION_URLS]
