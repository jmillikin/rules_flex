<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# rules_flex

Bazel rules for Flex, the Fast Lexical Analyzer.

<a id="flex"></a>

## flex

<pre>
load("@rules_flex//flex:flex.bzl", "flex")

flex(<a href="#flex-name">name</a>, <a href="#flex-src">src</a>, <a href="#flex-flex_options">flex_options</a>, <a href="#flex-language">language</a>)
</pre>

Generate C/C++ source code for a Flex lexical analyzer.

This rule exists for special cases where the build needs to perform further
modification of the generated `.c` / `.h` before compilation. Most users
will find the [`flex_cc_library`](#flex_cc_library) rule more convenient.

The output groups `cc_srcs` and `cc_hdrs` provide access to the generated
`{name}.c` / `{name}.cc` sources and (if available) the `{name}.h` header.

### Example

```starlark
load("@rules_flex//flex:flex.bzl", "flex")

flex(
    name = "hello",
    src = "hello.l",
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="flex-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="flex-src"></a>src |  A Flex source file.<br><br>Unless `language` is set, the source's file extension will determine whether Flex operates in C or C++ mode:<ul> <li>Inputs with file extension `.l` generate outputs `{name}.c` and `{name}.h`. </li><li>Inputs with file extension `.ll`, `.l++`, `.lxx`, or `.lpp` generate output     `{name}.cc`. This is equivalent to invoking Flex as `flex++`.</ul>The C++ output depends on `FlexLexer.h`, which is part of the Flex source distribution and may be obtained from the Flex toolchain.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |</li>  |
| <a id="flex-flex_options"></a>flex_options |  Additional options to pass to the `flex` command.<br><br>These will be added to the command args immediately before the source file.   | List of strings | optional |  `[]`  |
| <a id="flex-language"></a>language |  Which language to generate the lexer in.   | String | optional |  `""`  |


<a id="flex_cc_library"></a>

## flex_cc_library

<pre>
load("@rules_flex//flex:flex.bzl", "flex_cc_library")

flex_cc_library(<a href="#flex_cc_library-name">name</a>, <a href="#flex_cc_library-deps">deps</a>, <a href="#flex_cc_library-src">src</a>, <a href="#flex_cc_library-flex_options">flex_options</a>, <a href="#flex_cc_library-include_prefix">include_prefix</a>, <a href="#flex_cc_library-language">language</a>, <a href="#flex_cc_library-linkstatic">linkstatic</a>,
                <a href="#flex_cc_library-strip_include_prefix">strip_include_prefix</a>)
</pre>

Generate a C/C++ library for a Flex lexical analyzer.

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

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="flex_cc_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="flex_cc_library-deps"></a>deps |  A list of other C/C++ libraries to depend on.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="flex_cc_library-src"></a>src |  A Flex source file.<br><br>Unless `language` is set, the source's file extension will determine whether Flex operates in C or C++ mode:<ul> <li>Inputs with file extension `.l` generate outputs `{name}.c` and `{name}.h`. </li><li>Inputs with file extension `.ll`, `.l++`, `.lxx`, or `.lpp` generate output     `{name}.cc`. This is equivalent to invoking Flex as `flex++`.</ul>The C++ output depends on `FlexLexer.h`, which is part of the Flex source distribution and may be obtained from the Flex toolchain.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |</li>  |
| <a id="flex_cc_library-flex_options"></a>flex_options |  Additional options to pass to the `flex` command.<br><br>These will be added to the command args immediately before the source file.   | List of strings | optional |  `[]`  |
| <a id="flex_cc_library-include_prefix"></a>include_prefix |  A prefix to add to the path of the generated header.<br><br>See [`cc_library.include_prefix`](https://bazel.build/reference/be/c-cpp#cc_library.include_prefix) for more details.   | String | optional |  `""`  |
| <a id="flex_cc_library-language"></a>language |  Which language to generate the lexer in.   | String | optional |  `""`  |
| <a id="flex_cc_library-linkstatic"></a>linkstatic |  Disable creation of a shared library output.<br><br>See [`cc_library.linkstatic`](https://bazel.build/reference/be/c-cpp#cc_library.linkstatic) for more details.   | Boolean | optional |  `False`  |
| <a id="flex_cc_library-strip_include_prefix"></a>strip_include_prefix |  A prefix to strip from the path of the generated header.<br><br>See [`cc_library.strip_include_prefix`](https://bazel.build/reference/be/c-cpp#cc_library.strip_include_prefix) for more details.   | String | optional |  `""`  |


<a id="flex_toolchain_info"></a>

## flex_toolchain_info

<pre>
load("@rules_flex//flex:flex.bzl", "flex_toolchain_info")

flex_toolchain_info(<a href="#flex_toolchain_info-name">name</a>, <a href="#flex_toolchain_info-flex_env">flex_env</a>, <a href="#flex_toolchain_info-flex_lexer_h">flex_lexer_h</a>, <a href="#flex_toolchain_info-flex_tool">flex_tool</a>)
</pre>

Provides `ToolchainInfo` and `TemplateVariableInfo` for the Flex toolchain.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="flex_toolchain_info-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="flex_toolchain_info-flex_env"></a>flex_env |  Additional environment variables to set when running `flex_tool`.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="flex_toolchain_info-flex_lexer_h"></a>flex_lexer_h |  Label of `FlexLexer.h`, used for generated C++ lexers.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="flex_toolchain_info-flex_tool"></a>flex_tool |  A `FilesToRunProvider` for the `flex` binary.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="FlexToolchainInfo"></a>

## FlexToolchainInfo

<pre>
load("@rules_flex//flex:flex.bzl", "FlexToolchainInfo")

FlexToolchainInfo(<a href="#FlexToolchainInfo-all_files">all_files</a>, <a href="#FlexToolchainInfo-flex_tool">flex_tool</a>, <a href="#FlexToolchainInfo-flex_env">flex_env</a>, <a href="#FlexToolchainInfo-flex_lexer_h">flex_lexer_h</a>)
</pre>

Provider for a Flex toolchain.

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="FlexToolchainInfo-all_files"></a>all_files |  A `depset` containing all files comprising this Flex toolchain.    |
| <a id="FlexToolchainInfo-flex_tool"></a>flex_tool |  A `FilesToRunProvider` for the `flex` binary.    |
| <a id="FlexToolchainInfo-flex_env"></a>flex_env |  Additional environment variables to set when running `flex_tool`.    |
| <a id="FlexToolchainInfo-flex_lexer_h"></a>flex_lexer_h |  A `File` for the `FlexLexer.h` header.    |


<a id="flex_register_toolchains"></a>

## flex_register_toolchains

<pre>
load("@rules_flex//flex:flex.bzl", "flex_register_toolchains")

flex_register_toolchains(<a href="#flex_register_toolchains-version">version</a>, <a href="#flex_register_toolchains-extra_copts">extra_copts</a>)
</pre>

A helper function for Flex toolchains registration.

This workspace macro will create a [`flex_repository`](#flex_repository)
named `flex_v{version}` and register it as a Bazel toolchain.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="flex_register_toolchains-version"></a>version |  A supported version of Flex.   |  `"2.6.4"` |
| <a id="flex_register_toolchains-extra_copts"></a>extra_copts |  Additional C compiler options to use when building Flex.   |  `[]` |


<a id="flex_toolchain"></a>

## flex_toolchain

<pre>
load("@rules_flex//flex:flex.bzl", "flex_toolchain")

flex_toolchain(<a href="#flex_toolchain-ctx">ctx</a>)
</pre>

Returns the current [`FlexToolchainInfo`](#FlexToolchainInfo).

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="flex_toolchain-ctx"></a>ctx |  A rule context, where the rule has a toolchain dependency on [`FLEX_TOOLCHAIN_TYPE`](#FLEX_TOOLCHAIN_TYPE).   |  none |

**RETURNS**

A [`FlexToolchainInfo`](#FlexToolchainInfo).


<a id="flex_repository"></a>

## flex_repository

<pre>
load("@rules_flex//flex:flex.bzl", "flex_repository")

flex_repository(<a href="#flex_repository-name">name</a>, <a href="#flex_repository-extra_copts">extra_copts</a>, <a href="#flex_repository-extra_linkopts">extra_linkopts</a>, <a href="#flex_repository-patch_strip">patch_strip</a>, <a href="#flex_repository-patches">patches</a>, <a href="#flex_repository-version">version</a>)
</pre>

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

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="flex_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="flex_repository-extra_copts"></a>extra_copts |  Additional C compiler options to use when building Flex.   | List of strings | optional |  `[]`  |
| <a id="flex_repository-extra_linkopts"></a>extra_linkopts |  Additional linker options to use when building Flex.   | List of strings | optional |  `[]`  |
| <a id="flex_repository-patch_strip"></a>patch_strip |  Strip the specified number of leading components from patch file names.   | Integer | optional |  `0`  |
| <a id="flex_repository-patches"></a>patches |  A mapping from Flex versions to lists of patch files to apply, relative to the root of the Flex source repository. Each patch should be in standard [unified diff format](https://en.wikipedia.org/wiki/Diff#Unified_format).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> List of strings</a> | optional |  `{"2.6.4": ["//flex/patches:0001-fix-noline-for-top-directives.patch"]}`  |
| <a id="flex_repository-version"></a>version |  A supported version of Flex.   | String | required |  |


<a id="flex_toolchain_repository"></a>

## flex_toolchain_repository

<pre>
load("@rules_flex//flex:flex.bzl", "flex_toolchain_repository")

flex_toolchain_repository(<a href="#flex_toolchain_repository-name">name</a>, <a href="#flex_toolchain_repository-flex_repository">flex_repository</a>)
</pre>

Toolchain repository rule for Flex toolchains.

Toolchain repositories add a layer of indirection so that Bazel can resolve
toolchains without downloading additional dependencies.

The resulting repository will have the following targets:
- `//bin:flex` (an alias into the underlying [`flex_repository`]
  (#flex_repository))
- `//:toolchain`, which can be registered with Bazel.

### Example

```starlark
load(
    "@rules_flex//flex:flex.bzl",
    "flex_repository",
    "flex_toolchain_repository",
)

flex_repository(
    name = "flex_v2.6.4",
    version = "2.6.4",
)

flex_toolchain_repository(
    name = "flex",
    flex_repository = "@flex_v2.6.4",
)

register_toolchains("@flex//:toolchain")
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="flex_toolchain_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="flex_toolchain_repository-flex_repository"></a>flex_repository |  The name of a [`flex_repository`](#flex_repository).   | String | required |  |



<a id="flex_repository_ext"></a>

## flex_repository_ext

<pre>
flex_repository_ext = use_extension("@rules_flex//flex/extensions:flex_repository_ext.bzl", "flex_repository_ext")
flex_repository_ext.repository(<a href="#flex_repository_ext.repository-name">name</a>, <a href="#flex_repository_ext.repository-extra_copts">extra_copts</a>, <a href="#flex_repository_ext.repository-extra_linkopts">extra_linkopts</a>, <a href="#flex_repository_ext.repository-version">version</a>)
</pre>

Module extension for declaring dependencies on Flex.

The resulting repository will have the following targets:
- `//bin:flex` (an alias into the underlying [`flex_repository`]
  (#flex_repository))
- `//:toolchain`, which can be registered with Bazel.

### Example

```starlark
flex = use_extension(
    "@rules_flex//flex/extensions:flex_repository_ext.bzl",
    "flex_repository_ext",
)

flex.repository(name = "flex", version = "2.6.4")
use_repo(flex, "flex")
register_toolchains("@flex//:toolchain")
```


**TAG CLASSES**

<a id="flex_repository_ext.repository"></a>

### repository

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="flex_repository_ext.repository-name"></a>name |  An optional name for the repository.<br><br>The name must be unique within the set of names registered by this extension. If unset, the repository name will default to `"flex_v{version}"`.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | optional |  `""`  |
| <a id="flex_repository_ext.repository-extra_copts"></a>extra_copts |  Additional C compiler options to use when building Flex.   | List of strings | optional |  `[]`  |
| <a id="flex_repository_ext.repository-extra_linkopts"></a>extra_linkopts |  Additional linker options to use when building Flex.   | List of strings | optional |  `[]`  |
| <a id="flex_repository_ext.repository-version"></a>version |  A supported version of Flex.   | String | optional |  `"2.6.4"`  |



<a id="flex_toolchains_ext"></a>

## flex_toolchains_ext

<pre>
flex_toolchains_ext = use_extension("@rules_flex//flex/extensions:flex_toolchains_ext.bzl", "flex_toolchains_ext")
flex_toolchains_ext.toolchain(<a href="#flex_toolchains_ext.toolchain-name">name</a>, <a href="#flex_toolchains_ext.toolchain-flex_env">flex_env</a>, <a href="#flex_toolchains_ext.toolchain-flex_lexer_h">flex_lexer_h</a>, <a href="#flex_toolchains_ext.toolchain-flex_tool">flex_tool</a>)
</pre>

Module extension for declaring Flex toolchains with custom target binaries.

The resulting repository will have one subdirectory per named module tag, which
contains a `:toolchain` target that can be registered with Bazel.

### Example

```starlark
flex_toolchains = use_extension(
    "@rules_flex//flex/extensions:flex_toolchains_ext.bzl",
    "flex_toolchain_ext",
)

flex_toolchains.toolchain(
    name = "custom",
    flex_tool = "//custom_flex:flex",
    flex_lexer_h = "//custom_flex:flex_lexer_h",
)
use_repo(flex_toolchains, "flex_toolchains")
register_toolchains("@flex_toolchains//custom:toolchain")
```


**TAG CLASSES**

<a id="flex_toolchains_ext.toolchain"></a>

### toolchain

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="flex_toolchains_ext.toolchain-name"></a>name |  The name of the toolchain repository to create.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="flex_toolchains_ext.toolchain-flex_env"></a>flex_env |  Additional environment variables to set when running `flex_tool`.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="flex_toolchains_ext.toolchain-flex_lexer_h"></a>flex_lexer_h |  Label of `FlexLexer.h`, used for generated C++ lexers.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="flex_toolchains_ext.toolchain-flex_tool"></a>flex_tool |  The label of an `flex` executable target.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


