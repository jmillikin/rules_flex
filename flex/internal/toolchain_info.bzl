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

"""Bazel toolchain for Flex."""

load("//flex:providers.bzl", "FlexToolchainInfo")

_M4_TOOLCHAIN_TYPE = "@rules_m4//m4:toolchain_type"

def _template_vars(toolchain):
    return platform_common.TemplateVariableInfo({
        "FLEX": toolchain.flex_tool.executable.path,
    })

def _flex_toolchain_info(ctx):
    m4 = ctx.toolchains[_M4_TOOLCHAIN_TYPE].m4_toolchain
    flex_runfiles = ctx.attr.flex_tool[DefaultInfo].default_runfiles.files

    flex_env = dict(m4.m4_env)
    if "M4" not in flex_env:
        flex_env["M4"] = "{}.runfiles/{}/{}".format(
            ctx.executable.flex_tool.path,
            ctx.executable.flex_tool.owner.workspace_name,
            m4.m4_tool.executable.short_path,
        )

    flex_env.update(ctx.attr.flex_env)

    toolchain = FlexToolchainInfo(
        all_files = depset(
            direct = [ctx.executable.flex_tool],
            transitive = [flex_runfiles, m4.all_files],
        ),
        flex_tool = ctx.attr.flex_tool.files_to_run,
        flex_env = flex_env,
        flex_lexer_h = ctx.file.flex_lexer_h,
    )

    return [
        platform_common.ToolchainInfo(flex_toolchain = toolchain),
        _template_vars(toolchain),
    ]

flex_toolchain_info = rule(
    _flex_toolchain_info,
    attrs = {
        "flex_tool": attr.label(
            mandatory = True,
            executable = True,
            cfg = "host",
        ),
        "flex_env": attr.string_dict(),
        "flex_lexer_h": attr.label(
            mandatory = True,
            allow_single_file = [".h"],
        ),
    },
    provides = [
        platform_common.ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
    toolchains = [_M4_TOOLCHAIN_TYPE],
)
