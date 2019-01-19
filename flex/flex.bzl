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

"""Bazel build rules for Flex.

```python
load("@io_bazel_rules_m4//m4:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()

load("@io_bazel_rules_flex//flex:flex.bzl", "flex_register_toolchains")
flex_register_toolchains()
```
"""

load("@io_bazel_rules_m4//m4:m4.bzl", _m4_common = "m4_common")

# region Versions {{{

_LATEST = "2.6.4"

_VERSION_URLS = {
    "2.6.4": {
        "urls": ["https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"],
        "sha256": "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995",
    },
}

def _check_version(version):
    if version not in _VERSION_URLS:
        fail("Flex version {} not supported by rules_flex.".format(repr(version)))

# endregion }}}

# region Toolchain {{{

_TOOLCHAIN_TYPE = "@io_bazel_rules_flex//flex:toolchain_type"

_ToolchainInfo = provider(fields = ["files", "vars", "flex_executable", "flex_lexer_h"])

def _flex_toolchain_info(ctx):
    toolchain = _ToolchainInfo(
        flex_executable = ctx.executable.flex,
        flex_lexer_h = ctx.file.flex_lexer_h,
        files = depset([ctx.executable.flex]),
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
            executable = True,
            cfg = "host",
        ),
        "flex_lexer_h": attr.label(
            allow_single_file = [".h"],
        ),
    },
)

def _flex_toolchain_alias(ctx):
    toolchain = ctx.toolchains[_TOOLCHAIN_TYPE].flex_toolchain
    return [
        DefaultInfo(files = toolchain.files),
        toolchain,
        platform_common.TemplateVariableInfo(toolchain.vars),
    ]

flex_toolchain_alias = rule(
    _flex_toolchain_alias,
    toolchains = [_TOOLCHAIN_TYPE],
)

def flex_register_toolchains(version = _LATEST):
    _check_version(version)
    repo_name = "flex_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        flex_repository(
            name = repo_name,
            version = version,
        )
    native.register_toolchains("@io_bazel_rules_flex//flex/toolchains:v{}".format(version))

# endregion }}}

flex_common = struct(
    VERSIONS = list(_VERSION_URLS),
    ToolchainInfo = _ToolchainInfo,
    TOOLCHAIN_TYPE = _TOOLCHAIN_TYPE,
)

# region Build Rules {{{

# region rule(flex_lexer) {{{

def _flex_lexer(ctx):
    m4_toolchain = ctx.attr._m4_toolchain[_m4_common.ToolchainInfo]
    flex_toolchain = ctx.attr._flex_toolchain[flex_common.ToolchainInfo]

    args = ctx.actions.args()
    flex_inputs = m4_toolchain.files + flex_toolchain.files + ctx.files.src
    flex_outputs = []
    header = None
    flex_lexer_h = None

    if ctx.file.src.extension == "l":
        src_ext = "c"

        # The Flex manual documents that `--header-file` and `--c++` are incompatible.
        header = ctx.actions.declare_file("{}.h".format(ctx.attr.name))
        args.add("--header-file=" + header.path)
        flex_outputs.append(header)
    else:
        src_ext = "cc"
        args.add("--c++")
        flex_lexer_h = flex_toolchain.flex_lexer_h

    source = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, src_ext))
    args.add("--outfile=" + source.path)
    flex_outputs.append(source)

    args.add_all(ctx.attr.opts)
    args.add(ctx.file.src.path)

    ctx.actions.run(
        executable = flex_toolchain.flex_executable,
        arguments = [args],
        inputs = flex_inputs,
        outputs = flex_outputs,
        env = {
            "M4": m4_toolchain.m4_executable.path,
        },
        mnemonic = "Flex",
        progress_message = "Generating {}".format(ctx.label),
    )

    return [
        DefaultInfo(files = depset(flex_outputs)),
    ]

flex_lexer = rule(
    _flex_lexer,
    attrs = {
        "src": attr.label(
            mandatory = True,
            single_file = True,
            allow_files = [".l", ".ll", ".l++", ".lxx", ".lpp"],
        ),
        "opts": attr.string_list(
            allow_empty = True,
        ),
        "_flex_toolchain": attr.label(
            default = "//flex:toolchain",
        ),
        "_m4_toolchain": attr.label(
            default = "@io_bazel_rules_m4//m4:toolchain",
        ),
    },
)
"""Generate a Flex lexer implementation.

```python
load("@io_bazel_rules_flex//:flex.bzl", "flex_lexer")
flex_lexer(
    name = "hello",
    src = "hello.l",
)
cc_library(
    name = "hello_lib",
    srcs = [":hello"],
)
```
"""

# endregion }}}

# endregion }}}

# region Repository Rules {{{

def _flex_repository(ctx):
    version = ctx.attr.version
    _check_version(version)
    source = _VERSION_URLS[version]

    ctx.download_and_extract(
        url = source["urls"],
        sha256 = source["sha256"],
        stripPrefix = "flex-{}".format(version),
    )

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(name = repr(ctx.name)))
    ctx.symlink(ctx.attr._overlay_bin_BUILD, "bin/BUILD.bazel")
    ctx.template("BUILD.bazel", ctx.attr._overlay_BUILD, {
        "{VERSION}": version,
    })

flex_repository = repository_rule(
    _flex_repository,
    attrs = {
        "version": attr.string(mandatory = True),
        "_overlay_BUILD": attr.label(
            default = "//flex/internal:overlay/flex.BUILD",
            single_file = True,
        ),
        "_overlay_bin_BUILD": attr.label(
            default = "//flex/internal:overlay/flex_bin.BUILD",
            single_file = True,
        ),
    },
)

# endregion }}}
