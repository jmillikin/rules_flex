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

"""Definition of the `flex_cc_library` build rule."""

load("//flex:toolchain_type.bzl", "flex_toolchain")
load(
    "//flex/internal:flex_action.bzl",
    "FLEX_ACTION_TOOLCHAINS",
    "flex_action",
    "flex_action_attrs",
)

def _cc_library(ctx, flex_result):
    flex_lexer_h = flex_toolchain(ctx).flex_lexer_h
    cc_toolchain = ctx.attr._cc_toolchain[cc_common.CcToolchainInfo]

    cc_deps = cc_common.merge_cc_infos(cc_infos = [
        dep[CcInfo]
        for dep in ctx.attr.deps
    ])

    cc_public_hdrs = []
    cc_private_hdrs = []
    cc_system_includes = []
    if flex_result.header:
        cc_public_hdrs.append(flex_result.header)
    else:
        cc_private_hdrs.append(flex_lexer_h)
        cc_system_includes.append(flex_lexer_h.dirname)

    cc_feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.attr.features,
    )

    compile_kwargs = {}
    if ctx.attr.include_prefix:
        compile_kwargs["include_prefix"] = ctx.attr.include_prefix
    if ctx.attr.strip_include_prefix:
        compile_kwargs["strip_include_prefix"] = ctx.attr.strip_include_prefix

    (cc_compilation_context, cc_compilation_outputs) = cc_common.compile(
        name = ctx.attr.name,
        actions = ctx.actions,
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_feature_configuration,
        srcs = [flex_result.source],
        public_hdrs = cc_public_hdrs,
        private_hdrs = cc_private_hdrs,
        system_includes = cc_system_includes,
        compilation_contexts = [cc_deps.compilation_context],
        **compile_kwargs
    )

    (cc_linking_context, cc_linking_outputs) = cc_common.create_linking_context_from_compilation_outputs(
        name = ctx.attr.name,
        actions = ctx.actions,
        feature_configuration = cc_feature_configuration,
        cc_toolchain = cc_toolchain,
        compilation_outputs = cc_compilation_outputs,
        linking_contexts = [cc_deps.linking_context],
    )

    outs = []
    if cc_linking_outputs.library_to_link.static_library:
        outs.append(cc_linking_outputs.library_to_link.static_library)
    if cc_linking_outputs.library_to_link.dynamic_library:
        outs.append(cc_linking_outputs.library_to_link.dynamic_library)

    return struct(
        outs = depset(direct = outs),
        cc_info = CcInfo(
            compilation_context = cc_compilation_context,
            linking_context = cc_linking_context,
        ),
    )

def _flex_cc_library(ctx):
    result = flex_action(ctx)
    cc_lib = _cc_library(ctx, result)
    return [
        DefaultInfo(files = cc_lib.outs),
        cc_lib.cc_info,
    ]

flex_cc_library = rule(
    implementation = _flex_cc_library,
    doc = """Generate a C/C++ library for a Flex lexical analyzer.

### Example

```starlark
load("@rules_flex//flex:flex.bzl", "flex_cc_library")

flex_cc_library(
    name = "hello_lib",
    src = "hello.l",
)

cc_binary(
    name = "hello",
    srcs = ["hello_main.c"],
    deps = [":hello_lib"],
)
```
""",
    attrs = flex_action_attrs({
        "deps": attr.label_list(
            doc = "A list of other C/C++ libraries to depend on.",
            providers = [CcInfo],
        ),
        "include_prefix": attr.string(
            doc = """A prefix to add to the path of the generated header.

See [`cc_library.include_prefix`](https://bazel.build/reference/be/c-cpp#cc_library.include_prefix)
for more details.
""",
        ),
        "strip_include_prefix": attr.string(
            doc = """A prefix to strip from the path of the generated header.

See [`cc_library.strip_include_prefix`](https://bazel.build/reference/be/c-cpp#cc_library.strip_include_prefix)
for more details.
""",
        ),
        "_cc_toolchain": attr.label(
            default = "@bazel_tools//tools/cpp:current_cc_toolchain",
        ),
    }),
    provides = [
        CcInfo,
        DefaultInfo,
    ],
    toolchains = FLEX_ACTION_TOOLCHAINS,
    fragments = ["cpp"],
)
