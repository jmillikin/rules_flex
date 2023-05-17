# Copyright 2019 the rules_flex authors.
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

"""Definition of the `flex_repository` repository rule."""

load("//flex/internal:versions.bzl", "VERSION_URLS")

_FLEX_BUILD = """
filegroup(
    name = "flex_lexer_h",
    srcs = ["src/FlexLexer.h"],
    visibility = ["//:__subpackages__"],
)

FLEX_SRCS_v25 = glob(
    ["*.c", "*.h"],
    exclude = ["lib*.c"],
    allow_empty = True,
)

FLEX_SRCS_v26 = glob(
    ["src/*.c", "src/*.h"],
    exclude = ["src/lib*.c"],
    allow_empty = True,
)

cc_library(
    name = "flex_lib",
    srcs = FLEX_SRCS_v26 if len(FLEX_SRCS_v26) > 0 else FLEX_SRCS_v25,
    copts = [
        "-DHAVE_ASSERT_H",
        "-DHAVE_LIMITS_H",
        "-DHAVE_NETINET_IN_H",
        "-DHAVE_REGEX_H",
        "-DHAVE_SYS_STAT_H",
        "-DHAVE_SYS_WAIT_H",
        "-DHAVE_UNISTD_H",
        "-DSTDC_HEADERS",
        '-DVERSION="{VERSION}"',
        '-DM4="/bin/false"',
    ] + {EXTRA_COPTS},
    features = ["no_copts_tokenization"],
    visibility = ["//bin:__pkg__"],
)
"""

_FLEX_BIN_BUILD = """
filegroup(
    name = "flex_runfiles",
    srcs = [
        "@rules_m4//m4:current_m4_toolchain",
    ],
)
cc_binary(
    name = "flex",
    data = [":flex_runfiles"],
    visibility = ["//visibility:public"],
    deps = ["//:flex_lib"],
)
"""

_RULES_FLEX_INTERNAL_BUILD = """
load("@rules_flex//flex/internal:toolchain_info.bzl", "flex_toolchain_info")

flex_toolchain_info(
    name = "toolchain_info",
    flex_tool = "//bin:flex",
    flex_lexer_h = "//:flex_lexer_h",
    visibility = ["//visibility:public"],
)
"""

def _flex_repository(ctx):
    version = ctx.attr.version
    source = VERSION_URLS[version]

    ctx.download_and_extract(
        url = source["urls"],
        sha256 = source["sha256"],
        stripPrefix = "flex-{}".format(version),
    )

    # Fix build errors in older Flex due to use of undeclared functions.
    if version in ["2.5.36", "2.5.37"]:
        ctx.template("flexdef.h", "flexdef.h", substitutions = {
            "extern void lerrsf": "extern void lerrsf_fatal(const char *msg, const char arg[]);\nextern void lerrsf",
        }, executable = False)

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", _FLEX_BUILD.format(
        VERSION = version,
        EXTRA_COPTS = ctx.attr.extra_copts,
    ))
    ctx.file("bin/BUILD.bazel", _FLEX_BIN_BUILD)
    ctx.file("rules_flex_internal/BUILD.bazel", _RULES_FLEX_INTERNAL_BUILD)

flex_repository = repository_rule(
    implementation = _flex_repository,
    doc = """
Repository rule for Flex.

The resulting repository will have a `//bin:flex` executable target.

### Example

```starlark
load("@rules_flex//flex:flex.bzl", "flex_repository")

flex_repository(
    name = "flex_v2.6.4",
    version = "2.6.4",
)
```
""",
    attrs = {
        "version": attr.string(
            doc = "A supported version of Flex.",
            mandatory = True,
            values = sorted(VERSION_URLS),
        ),
        "extra_copts": attr.string_list(
            doc = "Additional C compiler options to use when building Flex.",
        ),
    },
)
