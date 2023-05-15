# Copyright 2023 the rules_flex authors.
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

"""Helpers for testing rules_flex."""

_BUILD = """
load("@rules_flex//flex/internal:versions.bzl", "VERSION_URLS")

filegroup(
    name = "all_versions",
    srcs = ["@flex_v{}//bin:flex".format(version) for version in VERSION_URLS],
    visibility = ["@rules_flex//tests:__pkg__"],
)
"""

_TOOLCHAINS_BUILD = """
load("@rules_flex//flex:toolchain_type.bzl", "FLEX_TOOLCHAIN_TYPE")
load("@rules_flex//flex/internal:versions.bzl", "VERSION_URLS")

[toolchain(
    name = "v{}".format(version),
    toolchain = "@flex_v{}//rules_flex_internal:toolchain_info".format(version),
    toolchain_type = FLEX_TOOLCHAIN_TYPE,
) for version in VERSION_URLS]
"""

def _rules_flex_testutil(ctx):
    ctx.file("WORKSPACE.bazel", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", _BUILD)
    ctx.file("toolchains/BUILD.bazel", _TOOLCHAINS_BUILD)

rules_flex_testutil = repository_rule(_rules_flex_testutil)
