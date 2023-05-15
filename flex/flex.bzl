# Copyright 2018 the rules_flex authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

"""Bazel rules for Flex, the Fast Lexical Analyzer."""

load(
    "//flex:providers.bzl",
    _FlexToolchainInfo = "FlexToolchainInfo",
)
load(
    "//flex:toolchain_type.bzl",
    _FLEX_TOOLCHAIN_TYPE = "FLEX_TOOLCHAIN_TYPE",
    _flex_toolchain = "flex_toolchain",
)
load(
    "//flex/internal:versions.bzl",
    "DEFAULT_VERSION",
    "check_version",
)
load(
    "//flex/rules:flex.bzl",
    _flex = "flex",
)
load(
    "//flex/rules:flex_cc_library.bzl",
    _flex_cc_library = "flex_cc_library",
)
load(
    "//flex/rules:flex_repository.bzl",
    _flex_repository = "flex_repository",
)

FLEX_TOOLCHAIN_TYPE = _FLEX_TOOLCHAIN_TYPE
flex = _flex
flex_cc_library = _flex_cc_library
flex_toolchain = _flex_toolchain
flex_repository = _flex_repository
FlexToolchainInfo = _FlexToolchainInfo

# buildifier: disable=unnamed-macro
def flex_register_toolchains(version = DEFAULT_VERSION, extra_copts = []):
    """A helper function for Flex toolchains registration.

    This workspace macro will create a [`flex_repository`](#flex_repository)
    named `flex_v{version}` and register it as a Bazel toolchain.

    Args:
        version: A supported version of Flex.
        extra_copts: Additional C compiler options to use when building Flex.
    """
    check_version(version)
    repo_name = "flex_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        flex_repository(
            name = repo_name,
            version = version,
            extra_copts = extra_copts,
        )
    native.register_toolchains("@rules_flex//flex/toolchains:v{}".format(version))
