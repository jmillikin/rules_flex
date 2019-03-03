load("@rules_flex//flex/internal:versions.bzl", "VERSION_URLS")
load("@rules_flex//flex/internal:toolchain.bzl", "TOOLCHAIN_TYPE")

[toolchain(
    name = "v{}".format(version),
    toolchain = "@rules_flex//flex/internal:toolchain_v{}".format(version),
    toolchain_type = TOOLCHAIN_TYPE,
) for version in VERSION_URLS]
