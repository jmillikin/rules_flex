load("@rules_flex//flex/internal:versions.bzl", "VERSION_URLS")
load("@rules_flex//flex/internal:toolchain.bzl", "FLEX_TOOLCHAIN_TYPE")

[toolchain(
    name = "v{}".format(version),
    toolchain = "@rules_flex//flex/internal:toolchain_v{}".format(version),
    toolchain_type = FLEX_TOOLCHAIN_TYPE,
) for version in VERSION_URLS]
