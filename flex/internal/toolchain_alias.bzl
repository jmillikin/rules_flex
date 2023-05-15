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

"""Shim rule for using Flex in a genrule or cc_library."""

load(
    "//flex:toolchain_type.bzl",
    "FLEX_TOOLCHAIN_TYPE",
    "flex_toolchain",
)

def _template_vars(toolchain):
    return platform_common.TemplateVariableInfo({
        "FLEX": toolchain.flex_tool.executable.path,
    })

def _flex_toolchain_alias(ctx):
    toolchain = flex_toolchain(ctx)
    flex_lexer_h = toolchain.flex_lexer_h
    return [
        DefaultInfo(files = toolchain.all_files),
        _template_vars(toolchain),
        CcInfo(
            compilation_context = cc_common.create_compilation_context(
                headers = depset(direct = [flex_lexer_h]),
                system_includes = depset(direct = [flex_lexer_h.dirname]),
            ),
        ),
    ]

flex_toolchain_alias = rule(
    _flex_toolchain_alias,
    toolchains = [FLEX_TOOLCHAIN_TYPE],
    provides = [
        DefaultInfo,
        CcInfo,
        platform_common.TemplateVariableInfo,
    ],
)
