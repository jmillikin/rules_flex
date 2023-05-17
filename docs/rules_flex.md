<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# rules_flex

Bazel rules for Flex, the Fast Lexical Analyzer.


<a id="flex"></a>

## flex

<pre>
flex(<a href="#flex-name">name</a>, <a href="#flex-flex_options">flex_options</a>, <a href="#flex-src">src</a>)
</pre>

Generate C/C++ source code for a Flex lexical analyzer.

This rule exists for special cases where the build needs to perform further
modification of the generated `.c` / `.h` before compilation. Most users
will find the [`flex_cc_library`](#flex_cc_library) rule more convenient.

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
| <a id="flex-flex_options"></a>flex_options |  Additional options to pass to the <code>flex</code> command.<br><br>These will be added to the command args immediately before the source file.   | List of strings | optional | <code>[]</code> |
| <a id="flex-src"></a>src |  A Flex source file.<br><br>The source's file extension will determine whether Flex operates in C or C++ mode:<ul> <li>Inputs with file extension <code>.l</code> generate outputs <code>{name}.c</code> and <code>{name}.h</code>. </li><li>Inputs with file extension <code>.ll</code>, <code>.l++</code>, <code>.lxx</code>, or <code>.lpp</code> generate output     <code>{name}.cc</code>. This is equivalent to invoking Flex as <code>flex++</code>.</ul>The C++ output depends on <code>FlexLexer.h</code>, which is part of the Flex source distribution and may be obtained from the Flex toolchain.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |</li>  |


<a id="flex_cc_library"></a>

## flex_cc_library

<pre>
flex_cc_library(<a href="#flex_cc_library-name">name</a>, <a href="#flex_cc_library-deps">deps</a>, <a href="#flex_cc_library-flex_options">flex_options</a>, <a href="#flex_cc_library-include_prefix">include_prefix</a>, <a href="#flex_cc_library-src">src</a>, <a href="#flex_cc_library-strip_include_prefix">strip_include_prefix</a>)
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
| <a id="flex_cc_library-deps"></a>deps |  A list of other C/C++ libraries to depend on.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="flex_cc_library-flex_options"></a>flex_options |  Additional options to pass to the <code>flex</code> command.<br><br>These will be added to the command args immediately before the source file.   | List of strings | optional | <code>[]</code> |
| <a id="flex_cc_library-include_prefix"></a>include_prefix |  A prefix to add to the path of the generated header.<br><br>See [<code>cc_library.include_prefix</code>](https://bazel.build/reference/be/c-cpp#cc_library.include_prefix) for more details.   | String | optional | <code>""</code> |
| <a id="flex_cc_library-src"></a>src |  A Flex source file.<br><br>The source's file extension will determine whether Flex operates in C or C++ mode:<ul> <li>Inputs with file extension <code>.l</code> generate outputs <code>{name}.c</code> and <code>{name}.h</code>. </li><li>Inputs with file extension <code>.ll</code>, <code>.l++</code>, <code>.lxx</code>, or <code>.lpp</code> generate output     <code>{name}.cc</code>. This is equivalent to invoking Flex as <code>flex++</code>.</ul>The C++ output depends on <code>FlexLexer.h</code>, which is part of the Flex source distribution and may be obtained from the Flex toolchain.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |</li>  |
| <a id="flex_cc_library-strip_include_prefix"></a>strip_include_prefix |  A prefix to strip from the path of the generated header.<br><br>See [<code>cc_library.strip_include_prefix</code>](https://bazel.build/reference/be/c-cpp#cc_library.strip_include_prefix) for more details.   | String | optional | <code>""</code> |


<a id="flex_repository"></a>

## flex_repository

<pre>
flex_repository(<a href="#flex_repository-name">name</a>, <a href="#flex_repository-extra_copts">extra_copts</a>, <a href="#flex_repository-repo_mapping">repo_mapping</a>, <a href="#flex_repository-version">version</a>)
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
| <a id="flex_repository-extra_copts"></a>extra_copts |  Additional C compiler options to use when building Flex.   | List of strings | optional | <code>[]</code> |
| <a id="flex_repository-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="flex_repository-version"></a>version |  A supported version of Flex.   | String | required |  |


<a id="flex_toolchain_repository"></a>

## flex_toolchain_repository

<pre>
flex_toolchain_repository(<a href="#flex_toolchain_repository-name">name</a>, <a href="#flex_toolchain_repository-flex_repository">flex_repository</a>, <a href="#flex_toolchain_repository-repo_mapping">repo_mapping</a>)
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
| <a id="flex_toolchain_repository-flex_repository"></a>flex_repository |  The name of a [<code>flex_repository</code>](#flex_repository).   | String | required |  |
| <a id="flex_toolchain_repository-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |


<a id="FlexToolchainInfo"></a>

## FlexToolchainInfo

<pre>
FlexToolchainInfo(<a href="#FlexToolchainInfo-all_files">all_files</a>, <a href="#FlexToolchainInfo-flex_tool">flex_tool</a>, <a href="#FlexToolchainInfo-flex_env">flex_env</a>, <a href="#FlexToolchainInfo-flex_lexer_h">flex_lexer_h</a>)
</pre>

Provider for a Flex toolchain.

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="FlexToolchainInfo-all_files"></a>all_files |  A <code>depset</code> containing all files comprising this Flex toolchain.    |
| <a id="FlexToolchainInfo-flex_tool"></a>flex_tool |  A <code>FilesToRunProvider</code> for the <code>flex</code> binary.    |
| <a id="FlexToolchainInfo-flex_env"></a>flex_env |  Additional environment variables to set when running <code>flex_tool</code>.    |
| <a id="FlexToolchainInfo-flex_lexer_h"></a>flex_lexer_h |  A <code>File</code> for the <code>FlexLexer.h</code> header.    |


<a id="flex_register_toolchains"></a>

## flex_register_toolchains

<pre>
flex_register_toolchains(<a href="#flex_register_toolchains-version">version</a>, <a href="#flex_register_toolchains-extra_copts">extra_copts</a>)
</pre>

A helper function for Flex toolchains registration.

This workspace macro will create a [`flex_repository`](#flex_repository)
named `flex_v{version}` and register it as a Bazel toolchain.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="flex_register_toolchains-version"></a>version |  A supported version of Flex.   |  <code>"2.6.4"</code> |
| <a id="flex_register_toolchains-extra_copts"></a>extra_copts |  Additional C compiler options to use when building Flex.   |  <code>[]</code> |


<a id="flex_toolchain"></a>

## flex_toolchain

<pre>
flex_toolchain(<a href="#flex_toolchain-ctx">ctx</a>)
</pre>

Returns the current [`FlexToolchainInfo`](#FlexToolchainInfo).

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="flex_toolchain-ctx"></a>ctx |  A rule context, where the rule has a toolchain dependency on [<code>FLEX_TOOLCHAIN_TYPE</code>](#FLEX_TOOLCHAIN_TYPE).   |  none |

**RETURNS**

A [`FlexToolchainInfo`](#FlexToolchainInfo).


