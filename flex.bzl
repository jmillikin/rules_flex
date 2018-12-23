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

load(
    "@io_bazel_rules_m4//m4:toolchain.bzl",
    _M4_TOOLCHAIN = "M4_TOOLCHAIN",
    _m4_context = "m4_context",
)
load(
    "//flex:toolchain.bzl",
    _FLEX_TOOLCHAIN = "FLEX_TOOLCHAIN",
    _flex_context = "flex_context",
)

_LATEST = "2.6.4"

_VERSION_URLS = {
    "2.6.4": {
        "urls": ["https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"],
        "sha256": "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995",
    },
}

FLEX_VERSIONS = list(_VERSION_URLS)

_SRC_EXT = {
    "c": "c",
    "c++": "cc",
}

_HDR_EXT = {
    "c": "h",
    "c++": "hh",
}

def _flex_lexer_impl(ctx):
    m4 = _m4_context(ctx)
    flex = _flex_context(ctx)

    out_src_ext = _SRC_EXT[ctx.attr.language]
    out_hdr_ext = _HDR_EXT[ctx.attr.language]

    out_src = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, out_src_ext))
    out_hdr = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, out_hdr_ext))

    inputs = m4.inputs + flex.inputs + ctx.files.src
    flex_outputs = [out_src, out_hdr]

    args = ctx.actions.args()
    args.add_all([
        "--outfile=" + out_src.path,
        "--header-file=" + out_hdr.path,
    ])

    if ctx.attr.skeleton:
        args.add("--skel=" + ctx.file.skeleton.path)
        inputs += ctx.files.skeleton

    rule_outputs = list(flex_outputs)
    extra_env = {}
    if ctx.attr.language == "c++":
        args.add("--c++")
        flex_lexer_h = ctx.actions.declare_file("{}_FlexLexer.h".format(ctx.attr.name))
        ctx.actions.expand_template(
            template = flex.toolchain._flex_internal.flex_lexer_h,
            output = flex_lexer_h,
            substitutions = {},
        )
        rule_outputs.append(flex_lexer_h)
        extra_env["FLEX_LEXER_H"] = '"{}"'.format(flex_lexer_h.short_path)

    args.add_all(ctx.attr.opts)
    args.add(ctx.file.src.path)

    ctx.actions.run(
        executable = flex.executable,
        arguments = [args],
        inputs = inputs,
        outputs = flex_outputs,
        env = m4.env + flex.env + extra_env,
        input_manifests = flex.input_manifests + m4.input_manifests,
        mnemonic = "Flex",
        progress_message = "Generating Flex lexer {} (from {})".format(ctx.label, ctx.attr.src.label),
    )
    return DefaultInfo(
        files = depset(rule_outputs),
    )

flex_lexer = rule(
    _flex_lexer_impl,
    attrs = {
        "src": attr.label(
            mandatory = True,
            single_file = True,
            allow_files = [".flex", ".l", ".ll", ".l++", ".lxx", ".lpp"],
        ),
        "opts": attr.string_list(
            allow_empty = True,
        ),
        "language": attr.string(
            default = "c",
            values = ["c", "c++"],
        ),
        "skeleton": attr.label(
            allow_single_file = True,
        ),
    },
    toolchains = [_FLEX_TOOLCHAIN, _M4_TOOLCHAIN],
)
"""Generate a Flex lexer implementation.

```python
load("@io_bazel_rules_flex//:flex.bzl", "flex_lexer")
flex_lexer(
    name = "hello",
    src = "hello.l",
)
cc_binary(
    name = "hello_bin",
    srcs = [":hello"],
)
```
"""

def _check_version(version):
    if version not in _VERSION_URLS:
        fail("Flex version {} not supported by rules_flex.".format(repr(version)))

_FLEX_LEXER_H_SHIM = """
const char *flex_lexer_h = getenv("FLEX_LEXER_H");
if (flex_lexer_h) {
    out("\\n#include ");
    outn(flex_lexer_h);
} else {
    outn("\\n#include <FlexLexer.h>");
}
"""

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
        "{VERSION}": version,
    })

    # Support runtime adjustment of the FlexLexer.h include line, so each flex_lexer
    # target can depend on the FlexLexer.h it was generated for.
    ctx.template("src/main.c", "src/main.c", substitutions = {
        'outn ("\\n#include <FlexLexer.h>");': _FLEX_LEXER_H_SHIM,
    }, executable = False)

flex_download = repository_rule(
    _flex_download,
    attrs = {
        "version": attr.string(mandatory = True),
        "_overlay_BUILD": attr.label(
            default = "@io_bazel_rules_flex//flex/internal:overlay/flex.BUILD",
            single_file = True,
        ),
        "_overlay_bin_BUILD": attr.label(
            default = "@io_bazel_rules_flex//flex/internal:overlay/flex_bin.BUILD",
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
    native.register_toolchains("@io_bazel_rules_flex//flex/toolchains:v{}_toolchain".format(version))
