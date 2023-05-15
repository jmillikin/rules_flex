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

"""Definition of the `flex_toolchain_repository` repository rule."""

_TOOLCHAIN_BUILD = """
load("@rules_flex//flex:toolchain_type.bzl", "FLEX_TOOLCHAIN_TYPE")

toolchain(
    name = "toolchain",
    toolchain = {flex_repo} + "//rules_flex_internal:toolchain_info",
    toolchain_type = FLEX_TOOLCHAIN_TYPE,
    visibility = ["//visibility:public"],
)
"""

_TOOLCHAIN_BIN_BUILD = """
alias(
    name = "flex",
    actual = {flex_repo} + "//bin:flex",
    visibility = ["//visibility:public"],
)
"""

def _flex_toolchain_repository(ctx):
    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", _TOOLCHAIN_BUILD.format(
        flex_repo = repr(ctx.attr.flex_repository),
    ))
    ctx.file("bin/BUILD.bazel", _TOOLCHAIN_BIN_BUILD.format(
        flex_repo = repr(ctx.attr.flex_repository),
    ))

flex_toolchain_repository = repository_rule(
    implementation = _flex_toolchain_repository,
    doc = """
Toolchain repository rule for Flex toolchains.

Toolchain repositories add a layer of indirection so that Bazel can resolve
toolchains without downloading additional dependencies.

The resulting repository will have the following targets:
- `//bin:flex` (an alias into the underlying [`flex_repository`]
  (#flex_repository))
- `//:toolchain`, which can be registered with Bazel.

### Example

```starlark
load(
    "@rules_flex//flex:flex.bzl",
    "flex_repository",
    "flex_toolchain_repository",
)

flex_repository(
    name = "flex_v2.6.4",
    version = "2.6.4",
)

flex_toolchain_repository(
    name = "flex",
    flex_repository = "@flex_v2.6.4",
)

register_toolchains("@flex//:toolchain")
```
""",
    attrs = {
        "flex_repository": attr.string(
            doc = "The name of a [`flex_repository`](#flex_repository).",
            mandatory = True,
        ),
    },
)
