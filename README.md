# Bazel build rules for Flex

## Overview

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_m4",
    urls = ["https://github.com/jmillikin/rules_m4/releases/download/v0.1/rules_m4-v0.1.tar.xz"],
    sha256 = "7bb12b8a5a96037ff3d36993a9bb5436c097e8d1287a573d5958b9d054c0a4f7",
)
load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()

http_archive(
    name = "rules_flex",
    # See https://github.com/jmillikin/rules_flex/releases for copy-pastable
    # URLs and checksums.
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
        "@rules_flex//flex:toolchain",
        "@rules_m4//m4:toolchain",
    ],
)
```

## Toolchains

```python
load("@rules_flex//flex:flex.bzl", "flex_common")
load("@rules_m4//m4:m4.bzl", "m4_common")

def _my_rule(ctx):
    flex_toolchain = flex_common.flex_toolchain(ctx)
    m4_toolchain = m4_common.m4_toolchain(ctx)
    ctx.actions.run(
        executable = flex_toolchain.flex_executable,
        inputs = depset(transitive = [
            flex_toolchain.files,
            m4_toolchain.files,
        ]),
        env = {"M4": m4_toolchain.m4_executable.path},
        # ...
    )

my_rule = rule(
    _my_rule,
    toolchains = [
        flex_common.TOOLCHAIN_TYPE,
        m4_common.TOOLCHAIN_TYPE,
    ],
)
```
