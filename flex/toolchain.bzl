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

load(
    "@io_bazel_rules_m4//m4:toolchain.bzl",
    _M4_TOOLCHAIN = "M4_TOOLCHAIN",
    _m4_context = "m4_context",
)

FLEX_TOOLCHAIN = "@io_bazel_rules_flex//flex:toolchain_type"

def _flex_toolchain(ctx):
    (inputs, _, input_manifests) = ctx.resolve_command(
        command = "flex",
        tools = [ctx.attr.flex],
    )
    return platform_common.ToolchainInfo(
        _flex_internal = struct(
            executable = ctx.executable.flex,
            inputs = inputs,
            input_manifests = input_manifests,
            flex_lexer_h = ctx.file.flex_lexer_h,
        ),
    )

flex_toolchain = rule(
    _flex_toolchain,
    attrs = {
        "flex": attr.label(
            executable = True,
            cfg = "host",
        ),
        "flex_lexer_h": attr.label(
            allow_single_file = [".h"],
        ),
    },
)

def flex_context(ctx):
    toolchain = ctx.toolchains[FLEX_TOOLCHAIN]
    impl = toolchain._flex_internal
    m4 = _m4_context(ctx)
    return struct(
        toolchain = toolchain,
        executable = impl.executable,
        inputs = impl.inputs,
        input_manifests = impl.input_manifests,
        env = {
            "M4": m4.executable.path,
        },
    )
