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

"""Helpers for running Flex as a build action."""

load(
    "//flex:toolchain_type.bzl",
    "FLEX_TOOLCHAIN_TYPE",
    "flex_toolchain",
)

_M4_TOOLCHAIN_TYPE = "@rules_m4//m4:toolchain_type"

FLEX_ACTION_TOOLCHAINS = [
    _M4_TOOLCHAIN_TYPE,
    FLEX_TOOLCHAIN_TYPE,
]

_FLEX_ACTION_ATTRS = {
    "src": attr.label(
        doc = """A Flex source file.

The source's file extension will determine whether Flex operates in C or C++
mode:
  - Inputs with file extension `.l` generate outputs `{name}.c` and `{name}.h`.
  - Inputs with file extension `.ll`, `.l++`, `.lxx`, or `.lpp` generate output
    `{name}.cc`. This is equivalent to invoking Flex as `flex++`.

The C++ output depends on `FlexLexer.h`, which is part of the Flex source
distribution and may be obtained from the Flex toolchain.
""",
        mandatory = True,
        allow_single_file = [".l", ".ll", ".l++", ".lxx", ".lpp"],
    ),
    "flex_options": attr.string_list(
        doc = """
Additional options to pass to the `flex` command.

These will be added to the command args immediately before the source file.
""",
    ),
    "_m4_deny_shell": attr.label(
        executable = True,
        cfg = "host",
        default = Label("//flex/internal:m4_deny_shell"),
    ),
}

def flex_action_attrs(rule_attrs):
    rule_attrs.update(_FLEX_ACTION_ATTRS)
    return rule_attrs

def flex_action(ctx):
    """Run Flex as a build action.

    The action's attributes must have been defined with `flex_action_attrs()`.

    Args:
        ctx: A rule context.

    Returns:
        A struct with `source` (generated source file), `header` (generated
        header file), and `outs` (depset of all generated outputs).
    """
    flex = flex_toolchain(ctx)

    args = ctx.actions.args()
    outputs = []
    header = None

    if ctx.file.src.extension == "l":
        src_ext = "c"

        # The Flex manual documents that `--header-file` and `--c++` are incompatible.
        header = ctx.actions.declare_file("{}.h".format(ctx.attr.name))
        args.add("--header-file=" + header.path)
        outputs.append(header)
    else:
        src_ext = "cc"
        args.add("--c++")

    source = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, src_ext))
    args.add("--outfile=" + source.path)
    outputs.append(source)

    args.add_all(ctx.attr.flex_options)
    args.add_all(ctx.files.src)

    ctx.actions.run(
        executable = flex.flex_tool,
        arguments = [args],
        inputs = depset(direct = ctx.files.src),
        outputs = outputs,
        tools = [
            ctx.executable._m4_deny_shell,
        ],
        env = dict(
            flex.flex_env,
            M4_SYSCMD_SHELL = ctx.executable._m4_deny_shell.path,
        ),
        mnemonic = "Flex",
        progress_message = "Flex {}".format(ctx.label),
    )

    return struct(
        source = source,
        header = header,
        outs = depset(direct = outputs),
    )
