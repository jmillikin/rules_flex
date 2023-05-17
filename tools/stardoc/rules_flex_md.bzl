"""# rules_flex

Bazel rules for Flex, the Fast Lexical Analyzer.
"""

load(
    "//flex:flex.bzl",
    _FlexToolchainInfo = "FlexToolchainInfo",
    _flex = "flex",
    _flex_cc_library = "flex_cc_library",
    _flex_register_toolchains = "flex_register_toolchains",
    _flex_repository = "flex_repository",
    _flex_toolchain = "flex_toolchain",
    _flex_toolchain_repository = "flex_toolchain_repository",
)

# FIXME: Enable when stardoc has been updated to support bzlmod globals.
#
# https://github.com/bazelbuild/stardoc/issues/123
#
# buildifier: disable=no-effect
"""
load(
    "//flex/extensions:flex_repository_ext.bzl",
    _flex_repository_ext = "flex_repository_ext",
)
"""

flex = _flex
flex_cc_library = _flex_cc_library
flex_register_toolchains = _flex_register_toolchains
flex_repository = _flex_repository
flex_toolchain = _flex_toolchain
flex_toolchain_repository = _flex_toolchain_repository
FlexToolchainInfo = _FlexToolchainInfo

# FIXME: Enable when stardoc has been updated to support bzlmod globals.
#
# https://github.com/bazelbuild/stardoc/issues/123
#
# buildifier: disable=no-effect
"""
flex_repository_ext = _flex_repository_ext
"""
