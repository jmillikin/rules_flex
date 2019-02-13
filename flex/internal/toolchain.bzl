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

TOOLCHAIN_TYPE = "@rules_flex//flex:toolchain_type"

FlexToolchainInfo = provider(fields = ["files", "vars", "flex_executable", "flex_lexer_h"])

def _flex_toolchain_info(ctx):
    toolchain = FlexToolchainInfo(
        flex_executable = ctx.executable.flex,
        flex_lexer_h = ctx.file.flex_lexer_h,
        files = depset(direct = [ctx.executable.flex]),
        vars = {"FLEX": ctx.executable.flex.path},
    )
    return [
        platform_common.ToolchainInfo(flex_toolchain = toolchain),
        platform_common.TemplateVariableInfo(toolchain.vars),
    ]

flex_toolchain_info = rule(
    _flex_toolchain_info,
    attrs = {
        "flex": attr.label(
            mandatory = True,
            executable = True,
            cfg = "host",
        ),
        "flex_lexer_h": attr.label(
            mandatory = True,
            allow_single_file = [".h"],
        ),
    },
    provides = [
        platform_common.ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
)

def _flex_toolchain_alias(ctx):
    toolchain = ctx.toolchains[TOOLCHAIN_TYPE].flex_toolchain
    return [
        DefaultInfo(files = toolchain.files),
        toolchain,
        platform_common.TemplateVariableInfo(toolchain.vars),
    ]

flex_toolchain_alias = rule(
    _flex_toolchain_alias,
    toolchains = [TOOLCHAIN_TYPE],
    provides = [
        DefaultInfo,
        FlexToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
)
