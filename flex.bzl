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
load("@io_bazel_rules_m4//:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()

load("@io_bazel_rules_flex//:flex.bzl", "flex_register_toolchains")
flex_register_toolchains()
```
"""

load("@io_bazel_rules_m4//:m4.bzl", "M4_TOOLCHAIN")

_LATEST = "2.6.4"

_VERSION_URLS = {
    "2.6.4": {
        "urls": ["https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"],
        "sha256": "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995",
    },
}

FLEX_TOOLCHAIN = "@io_bazel_rules_flex//flex:toolchain_type"

FLEX_VERSIONS = list(_VERSION_URLS)

def _flex_lexer(ctx):
    m4 = ctx.toolchains[M4_TOOLCHAIN].m4
    flex = ctx.toolchains[FLEX_TOOLCHAIN].flex

    out_src_ext = {
        "l": "c",
        "ll": "cc",
        "l++": "c++",
        "lxx": "cxx",
        "lpp": "cpp",
    }[ctx.file.src.extension]
    out_hdr_ext = {
        "l": "h",
        "ll": "hh",
        "l++": "h++",
        "lxx": "hxx",
        "lpp": "hpp",
    }[ctx.file.src.extension]

    out_src = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, out_src_ext))
    out_hdr = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, out_hdr_ext))

    ctx.actions.run(
        executable = flex.executable,
        arguments = [
            "--outfile=" + out_src.path,
            "--header-file=" + out_hdr.path,
            ctx.file.src.path,
        ],
        inputs = [ctx.file.src] + flex.inputs + m4.inputs,
        outputs = [out_src, out_hdr],
        env = m4.env(ctx) + flex.env(ctx),
        input_manifests = m4.input_manifests + flex.input_manifests,
        mnemonic = "Flex",
        progress_message = "Generating Flex lexer {} (from {})".format(ctx.label, ctx.attr.src.label),
    )
    return DefaultInfo(
        files = depset([out_src, out_hdr]),
    )

flex_lexer = rule(
    _flex_lexer,
    attrs = {
        "src": attr.label(
            mandatory = True,
            single_file = True,
            allow_files = [".l", ".ll", ".l++", ".lxx", ".lpp"],
        ),
    },
    toolchains = [FLEX_TOOLCHAIN, M4_TOOLCHAIN],
)

def _flex_env(ctx):
    m4 = ctx.toolchains[M4_TOOLCHAIN].m4
    return {
        "M4": m4.executable.path,
    }

def _flex_toolchain(ctx):
    (inputs, _, input_manifests) = ctx.resolve_command(
        command = "flex",
        tools = [ctx.attr.flex],
    )
    return [
        platform_common.ToolchainInfo(
            flex = struct(
                executable = ctx.executable.flex,
                inputs = inputs,
                input_manifests = input_manifests,
                env = _flex_env,
            ),
        ),
    ]

flex_toolchain = rule(
    _flex_toolchain,
    attrs = {
        "flex": attr.label(
            executable = True,
            cfg = "host",
        ),
    },
)

def _check_version(version):
    if version not in _VERSION_URLS:
        fail("Flex version {} not supported by rules_flex.".format(repr(version)))

def _flex_download(ctx):
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
        "version": version,
    })

flex_download = repository_rule(
    _flex_download,
    attrs = {
        "version": attr.string(mandatory = True),
        "_overlay_BUILD": attr.label(
            default = "@io_bazel_rules_flex//internal:overlay/flex_BUILD",
            single_file = True,
        ),
        "_overlay_bin_BUILD": attr.label(
            default = "@io_bazel_rules_flex//internal:overlay/flex_bin_BUILD",
            single_file = True,
        ),
    },
)

def flex_register_toolchains(version = _LATEST):
    _check_version(version)
    repo_name = "flex_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        flex_download(
            name = repo_name,
            version = version,
        )
    native.register_toolchains("@io_bazel_rules_flex//toolchains:v{}_toolchain".format(version))
