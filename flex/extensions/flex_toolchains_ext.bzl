# Copyright 2026 the rules_flex authors.
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

"""Definition of the `flex_toolchains_ext` module extension."""

_BUILD = """
load("@rules_flex//flex:toolchain_type.bzl", "FLEX_TOOLCHAIN_TYPE")
load("@rules_flex//flex/rules:flex_toolchain_info.bzl", "flex_toolchain_info")

flex_toolchain_info(
    name = "toolchain_info",
    flex_tool = {flex_tool},
    flex_env = {flex_env},
    flex_lexer_h = {flex_lexer_h},
)

toolchain(
    name = "toolchain",
    toolchain = ":toolchain_info",
    toolchain_type = FLEX_TOOLCHAIN_TYPE,
    visibility = ["//visibility:public"],
)
"""

def _flex_toolchains_repo_impl(ctx):
    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", "")
    for (toolchain_name, flex_tool) in ctx.attr.flex_tool.items():
        flex_env = ctx.attr.flex_env.get(toolchain_name, "{}")
        flex_lexer_h = ctx.attr.flex_lexer_h[toolchain_name]
        ctx.file(toolchain_name + "/BUILD.bazel", _BUILD.format(
            flex_tool = repr(str(flex_tool)),
            flex_env = json.decode(flex_env),
            flex_lexer_h = repr(str(flex_lexer_h)),
        ))

_flex_toolchains_repo = repository_rule(
    implementation = _flex_toolchains_repo_impl,
    attrs = {
        "flex_tool": attr.string_keyed_label_dict(),
        "flex_env": attr.string_dict(),
        "flex_lexer_h": attr.string_keyed_label_dict(),
    },
)

def _flex_toolchains_ext(module_ctx):
    root_direct_dep = False
    root_direct_dev_dep = False

    flex_tools = {}
    flex_envs = {}
    flex_lexer_headers = {}
    for module in module_ctx.modules:
        for config in module.tags.toolchain:
            flex_tools[config.name] = config.flex_tool
            flex_lexer_headers[config.name] = config.flex_lexer_h
            if config.flex_env:
                flex_envs[config.name] = json.encode(config.flex_env)
            if module.is_root:
                if module_ctx.is_dev_dependency(config):
                    root_direct_dev_dep = True
                else:
                    root_direct_dep = True

    _flex_toolchains_repo(
        name = "flex_toolchains",
        flex_tool = flex_tools,
        flex_env = flex_envs,
        flex_lexer_h = flex_lexer_headers,
    )

    root_direct_deps = []
    if root_direct_dep:
        root_direct_deps.append("flex_toolchains")
    root_direct_dev_deps = []
    if root_direct_dev_dep:
        root_direct_dev_deps.append("flex_toolchains")

    return module_ctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = root_direct_deps,
        root_module_direct_dev_deps = root_direct_dev_deps,
    )

_TOOLCHAIN_TAG_ATTRS = {
    "name": attr.string(
        doc = "The name of the toolchain repository to create.",
        mandatory = True,
    ),
    "flex_tool": attr.label(
        doc = "The label of an `flex` executable target.",
        mandatory = True,
    ),
    "flex_env": attr.string_dict(
        doc = "Additional environment variables to set when running `flex_tool`.",
    ),
    "flex_lexer_h": attr.label(
        doc = "Label of `FlexLexer.h`, used for generated C++ lexers.",
        mandatory = True,
        allow_single_file = [".h"],
    ),
}

flex_toolchains_ext = module_extension(
    implementation = _flex_toolchains_ext,
    doc = """
Module extension for declaring Flex toolchains with custom target binaries.

The resulting repository will have one subdirectory per named module tag, which
contains a `:toolchain` target that can be registered with Bazel.

### Example

```starlark
flex_toolchains = use_extension(
    "@rules_flex//flex/extensions:flex_toolchains_ext.bzl",
    "flex_toolchain_ext",
)

flex_toolchains.toolchain(
    name = "custom",
    flex_tool = "//custom_flex:flex",
    flex_lexer_h = "//custom_flex:flex_lexer_h",
)
use_repo(flex_toolchains, "flex_toolchains")
register_toolchains("@flex_toolchains//custom:toolchain")
```
""",
    tag_classes = {
        "toolchain": tag_class(
            attrs = _TOOLCHAIN_TAG_ATTRS,
        ),
    },
)
