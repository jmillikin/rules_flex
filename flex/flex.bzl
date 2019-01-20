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

load(
    "@bazel_tools//tools/build_defs/cc:action_names.bzl",
    _ACTION_COMPILE_C = "C_COMPILE_ACTION_NAME",
    _ACTION_COMPILE_CXX = "CPP_COMPILE_ACTION_NAME",
    _ACTION_LINK_DYNAMIC = "CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME",
    _ACTION_LINK_STATIC = "CPP_LINK_STATIC_LIBRARY_ACTION_NAME",
)
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

_COMMON_ATTR = {
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
}

def _flex_common(ctx):
    m4_toolchain = ctx.attr._m4_toolchain[_m4_common.ToolchainInfo]
    flex_toolchain = ctx.attr._flex_toolchain[flex_common.ToolchainInfo]

    args = ctx.actions.args()
    flex_inputs = m4_toolchain.files + flex_toolchain.files + ctx.files.src
    flex_outputs = []
    header = None

    if ctx.file.src.extension == "l":
        src_ext = "c"

        # The Flex manual documents that `--header-file` and `--c++` are incompatible.
        header = ctx.actions.declare_file("{}.h".format(ctx.attr.name))
        args.add("--header-file=" + header.path)
        flex_outputs.append(header)
    else:
        src_ext = "cc"
        args.add("--c++")

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

    return struct(
        source = source,
        header = header,
        outs = depset(flex_outputs),
    )

# region rule(flex) {{{

def _flex(ctx):
    result = _flex_common(ctx)
    return DefaultInfo(files = result.outs)

flex = rule(
    _flex,
    attrs = _COMMON_ATTR,
)
"""Generate a Flex lexer implementation.

```python
load("@io_bazel_rules_flex//flex:flex.bzl", "flex")
flex(
    name = "hello",
    src = "hello.l",
)
cc_binary(
    name = "hello_bin",
    srcs = [":hello"],
)
```
"""

# endregion }}}

# region rule(flex_cc_library) {{{

# region C++ toolchain integration {{{

def _cc_compile(ctx, cc_toolchain, cc_features, deps, source, header, out_obj, use_pic):
    toolchain_inputs = ctx.attr._cc_toolchain[DefaultInfo].files
    flex_toolchain = ctx.attr._flex_toolchain[flex_common.ToolchainInfo]

    headers = []
    isystem = []
    if source.extension == "c":
        cc_action = _ACTION_COMPILE_C
    else:
        cc_action = _ACTION_COMPILE_CXX
        flex_lexer_h = flex_toolchain.flex_lexer_h
        headers.append(flex_lexer_h)
        isystem.append(flex_lexer_h.dirname)

    cc = cc_common.get_tool_for_action(
        feature_configuration = cc_features,
        action_name = cc_action,
    )

    cc_vars = cc_common.create_compile_variables(
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_features,
        source_file = source.path,
        output_file = out_obj.path,
        use_pic = use_pic,
        include_directories = deps.compilation_context.includes,
        quote_include_directories = depset([
            ".",
            ctx.genfiles_dir.path,
            ctx.bin_dir.path,
        ]) + deps.compilation_context.quote_includes,
        system_include_directories = deps.compilation_context.system_includes + depset(isystem),
        preprocessor_defines = deps.compilation_context.defines,
    )

    cc_argv = cc_common.get_memory_inefficient_command_line(
        feature_configuration = cc_features,
        action_name = cc_action,
        variables = cc_vars,
    )

    cc_env = cc_common.get_environment_variables(
        feature_configuration = cc_features,
        action_name = cc_action,
        variables = cc_vars,
    )

    ctx.actions.run(
        inputs = toolchain_inputs + deps.compilation_context.headers + depset([source] + headers),
        outputs = [out_obj],
        executable = cc,
        arguments = cc_argv,
        mnemonic = "CppCompile",
        progress_message = "Compiling {}".format(source.short_path),
        env = cc_env,
    )

def _cc_link_static(ctx, cc_toolchain, cc_features, deps, obj, out_lib):
    toolchain_inputs = ctx.attr._cc_toolchain[DefaultInfo].files

    ar = cc_common.get_tool_for_action(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_STATIC,
    )

    ar_vars = cc_common.create_link_variables(
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_features,
        output_file = out_lib.path,
        is_using_linker = False,
        is_static_linking_mode = True,
    )

    ar_argv = cc_common.get_memory_inefficient_command_line(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_STATIC,
        variables = ar_vars,
    )

    ar_env = cc_common.get_environment_variables(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_STATIC,
        variables = ar_vars,
    )

    ctx.actions.run(
        inputs = toolchain_inputs + depset([obj]),
        outputs = [out_lib],
        executable = ar,
        arguments = ar_argv + [obj.path],
        mnemonic = "CppLink",
        progress_message = "Linking {}".format(out_lib.short_path),
        env = ar_env,
    )

def _cc_link_dynamic(ctx, cc_toolchain, cc_features, deps, obj, out_lib):
    toolchain_inputs = ctx.attr._cc_toolchain[DefaultInfo].files

    ld = cc_common.get_tool_for_action(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_DYNAMIC,
    )

    ld_vars = cc_common.create_link_variables(
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_features,
        output_file = out_lib.path,
        is_using_linker = True,
        is_static_linking_mode = False,
        is_linking_dynamic_library = True,
    )

    ld_argv = cc_common.get_memory_inefficient_command_line(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_DYNAMIC,
        variables = ld_vars,
    )

    ld_env = cc_common.get_environment_variables(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_DYNAMIC,
        variables = ld_vars,
    )

    ctx.actions.run(
        inputs = toolchain_inputs + depset([obj]),
        outputs = [out_lib],
        executable = ld,
        arguments = ld_argv + [obj.path],
        mnemonic = "CppLink",
        progress_message = "Linking {}".format(out_lib.short_path),
        env = ld_env,
    )

def _obj_name(ctx, src, pic):
    ext = src.extension
    base = src.basename[:-len(ext)]
    pic_ext = ""
    if pic:
        pic_ext = "pic."
    return "_objs/{}/{}{}o".format(ctx.attr.name, base, pic_ext)

def _build_cc_info(ctx, source, header):
    cc_toolchain = ctx.attr._cc_toolchain[cc_common.CcToolchainInfo]
    flex_toolchain = ctx.attr._flex_toolchain[flex_common.ToolchainInfo]

    cc_features = cc_common.configure_features(
        cc_toolchain = cc_toolchain,
    )
    ar_features = cc_common.configure_features(
        cc_toolchain = cc_toolchain,
    )
    ld_features = cc_common.configure_features(
        cc_toolchain = cc_toolchain,
        requested_features = ["dynamic_linking_mode"],
    )

    use_pic = cc_toolchain.needs_pic_for_dynamic_libraries(
        feature_configuration = ld_features,
    )

    deps = cc_common.merge_cc_infos(cc_infos = [
        dep[CcInfo]
        for dep in ctx.attr.deps
    ])

    out_obj = ctx.actions.declare_file(_obj_name(ctx, source, use_pic))
    out_lib = ctx.actions.declare_file("lib{}.a".format(ctx.attr.name))
    out_dylib = ctx.actions.declare_file("lib{}.so".format(ctx.attr.name))

    out_headers = []
    out_isystem = []
    if header:
        out_headers.append(header)
    else:
        flex_lexer_h = flex_toolchain.flex_lexer_h
        out_headers.append(flex_lexer_h)
        out_isystem.append(flex_lexer_h.dirname)

    _cc_compile(ctx, cc_toolchain, cc_features, deps, source, header, out_obj, use_pic)
    _cc_link_static(ctx, cc_toolchain, ar_features, deps, out_obj, out_lib)
    _cc_link_dynamic(ctx, cc_toolchain, ld_features, deps, out_obj, out_dylib)

    cc_info = CcInfo(
        compilation_context = cc_common.create_compilation_context(
            headers = depset(out_headers),
            system_includes = depset(out_isystem),
        ),
        linking_context = cc_common.create_linking_context(
            libraries_to_link = [
                cc_common.create_library_to_link(
                    actions = ctx.actions,
                    feature_configuration = ar_features,
                    cc_toolchain = cc_toolchain,
                    static_library = None if use_pic else out_lib,
                    pic_static_library = out_lib if use_pic else None,
                ),
                cc_common.create_library_to_link(
                    actions = ctx.actions,
                    feature_configuration = ld_features,
                    cc_toolchain = cc_toolchain,
                    dynamic_library = out_dylib,
                ),
            ],
        ),
    )

    return struct(
        cc_info = cc_common.merge_cc_infos(cc_infos = [deps, cc_info]),
        outs = depset([out_lib, out_dylib]),
    )

# endregion }}}

def _flex_cc_library(ctx):
    result = _flex_common(ctx)
    cc = _build_cc_info(ctx, result.source, result.header)
    return [
        DefaultInfo(files = cc.outs),
        cc.cc_info,
    ]

flex_cc_library = rule(
    _flex_cc_library,
    attrs = _COMMON_ATTR + {
        "deps": attr.label_list(
            allow_empty = True,
            providers = [CcInfo],
        ),
        "_cc_toolchain": attr.label(
            default = "@bazel_tools//tools/cpp:current_cc_toolchain",
        ),
    },
)
"""Generate a Flex lexer implementation.

```python
load("@io_bazel_rules_flex//flex:flex.bzl", "flex_cc_library")
flex_cc_library(
    name = "hello",
    src = "hello.l",
)
cc_binary(
    name = "hello_bin",
    deps = [":hello"],
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
