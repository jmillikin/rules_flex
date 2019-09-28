# Bazel build rules for Flex

## Overview

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_m4",
    urls = ["https://github.com/jmillikin/rules_m4/releases/download/v0.2/rules_m4-v0.2.tar.xz"],
    sha256 = "c67fa9891bb19e9e6c1050003ba648d35383b8cb3c9572f397ad24040fb7f0eb",
)
load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()

http_archive(
    name = "rules_flex",
    urls = ["https://github.com/jmillikin/rules_flex/releases/download/v0.2/rules_flex-v0.2.tar.xz"],
    sha256 = "f1685512937c2e33a7ebc4d5c6cf38ed282c2ce3b7a9c7c0b542db7e5db59d52",
)
load("@rules_flex//flex:flex.bzl", "flex_register_toolchains")
flex_register_toolchains()
```

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

## Other Rules

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

## Toolchains

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
    _my_rule,
    toolchains = [
        FLEX_TOOLCHAIN_TYPE,
        M4_TOOLCHAIN_TYPE,
    ],
)
```
