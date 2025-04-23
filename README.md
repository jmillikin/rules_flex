# Bazel build rules for Flex

This Bazel ruleset allows [Flex] to be integrated into a Bazel build. It can
be used to generate lexical analyzers ("lexers") in C or C++.

API reference: [docs/rules_flex.md](docs/rules_flex.md)

[Flex]: https://github.com/westes/flex

## Setup

Add the following to your `MODULE.bazel`:

```python
bazel_dep(name = "rules_flex", version = "0.3.2")
```

To specify a version or build with additional C compiler options, use the
`flex_repository_ext` module extension:

```python
flex = use_extension(
    "@rules_flex//flex/extensions:flex_repository_ext.bzl",
    "flex_repository_ext",
)
flex.repository(
    name = "flex",
    version = "2.6.4",
    extra_copts = ["-O3"],
)
use_repo(flex, "flex")
register_toolchains("@flex//:toolchain")
```

Note that repository names registered with a given bzlmod module extension must
be unique within the scope of that extension. See the [Bazel module extensions]
documentation for more details.

[Bazel module extensions]: https://bazel.build/external/extension

## Examples

Integrating Flex into a C/C++ dependency graph:

```python
load("@rules_flex//flex:flex.bzl", "flex_cc_library")

flex_cc_library(
    name = "hello",
    src = "hello.l",
)

cc_binary(
    name = "hello_bin",
    deps = [":hello"],
)
```

Generating `.c` / `.h` / `.cc` source files (not as a `CcInfo`):

```python
load("@rules_flex//flex:flex.bzl", "flex")

flex(
    name = "hello_bin_srcs",
    src = "hello.l",
)

cc_binary(
    name = "hello_bin",
    srcs = [":hello_bin_srcs"],
)
```

Running Flex in a `genrule`:

```python
genrule(
    name = "hello_gen",
    srcs = ["hello.l"],
    outs = ["hello_gen.c"],
    cmd = "M4=$(M4) $(FLEX) --outfile=$@ $<",
    toolchains = [
        "@rules_flex//flex:current_flex_toolchain",
        "@rules_m4//m4:current_m4_toolchain",
    ],
)
```

Writing a custom rule that depends on Flex as a toolchain:

```python
load("@rules_flex//flex:flex.bzl", "FLEX_TOOLCHAIN_TYPE", "flex_toolchain")
load("@rules_m4//m4:m4.bzl", "M4_TOOLCHAIN_TYPE")

def _my_rule(ctx):
    flex = flex_toolchain(ctx)
    ctx.actions.run(
        executable = flex.flex_tool,
        env = flex.flex_env,
        # ...
    )

my_rule = rule(
    implementation = _my_rule,
    toolchains = [
        FLEX_TOOLCHAIN_TYPE,
        M4_TOOLCHAIN_TYPE,
    ],
)
```
