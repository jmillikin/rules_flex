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

"""Definition of the `flex_toolchain_info` rule."""

load("//flex:providers.bzl", "FlexToolchainInfo")

def _template_vars(toolchain):
    return platform_common.TemplateVariableInfo({
        "FLEX": toolchain.flex_tool.executable.path,
    })

def _flex_toolchain_info(ctx):
    flex_runfiles = ctx.attr.flex_tool[DefaultInfo].default_runfiles.files
    toolchain = FlexToolchainInfo(
        all_files = depset(
            direct = [ctx.executable.flex_tool],
            transitive = [flex_runfiles],
        ),
        flex_tool = ctx.attr.flex_tool.files_to_run,
        flex_env = ctx.attr.flex_env,
        flex_lexer_h = ctx.file.flex_lexer_h,
    )
    return [
        platform_common.ToolchainInfo(flex_toolchain = toolchain),
        _template_vars(toolchain),
    ]

flex_toolchain_info = rule(
    _flex_toolchain_info,
    doc = """
Provides `ToolchainInfo` and `TemplateVariableInfo` for the Flex toolchain.
""",
    attrs = {
        "flex_tool": attr.label(
            doc = "A `FilesToRunProvider` for the `flex` binary.",
            mandatory = True,
            executable = True,
            cfg = "exec",
        ),
        "flex_env": attr.string_dict(
            doc = "Additional environment variables to set when running `flex_tool`.",
        ),
        "flex_lexer_h": attr.label(
            doc = "Label of `FlexLexer.h`, used for generated C++ lexers.",
            mandatory = True,
            allow_single_file = [".h"],
        ),
    },
    provides = [
        platform_common.ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
)
