# Copyright 2023 the rules_flex authors.
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

"""Definition of the `flex_repository_ext` module extension."""

load(
    "//flex/internal:versions.bzl",
    "DEFAULT_VERSION",
    "VERSION_URLS",
)
load(
    "//flex/rules:flex_repository.bzl",
    "flex_repository",
)
load(
    "//flex/rules:flex_toolchain_repository.bzl",
    "flex_toolchain_repository",
)

def _flex_repo_name(version, extra_copts):
    # copts_key = "{:08X}".format(hash(repr(extra_copts)))
    copts_key = "%X" % (hash(repr(extra_copts)),)
    if len(copts_key) < 8:
        copts_key = "00000000"[:8 - len(copts_key)] + copts_key
    return "flex_v{}__cfg{}".format(version, copts_key)

def _flex_repository_ext(module_ctx):
    root_direct_deps = []
    root_direct_dev_deps = []
    flex_repo_names = {}

    for module in module_ctx.modules:
        for config in module.tags.repository:
            name = config.name
            if not name:
                name = "flex_v{}".format(config.version)

            flex_repo_name = _flex_repo_name(config.version, config.extra_copts)

            flex_toolchain_repository(
                name = name,
                flex_repository = "@" + flex_repo_name,
            )

            if module.is_root:
                if module_ctx.is_dev_dependency(config):
                    root_direct_dev_deps.append(name)
                else:
                    root_direct_deps.append(name)

            if flex_repo_name not in flex_repo_names:
                flex_repo_names[flex_repo_name] = True
                flex_repository(
                    name = flex_repo_name,
                    version = config.version,
                    extra_copts = config.extra_copts,
                )

    return module_ctx.extension_metadata(
        root_module_direct_deps = root_direct_deps,
        root_module_direct_dev_deps = root_direct_dev_deps,
    )

_REPOSITORY_TAG_ATTRS = {
    "name": attr.string(
        doc = """An optional name for the repository.

The name must be unique within the set of names registered by this extension.
If unset, the repository name will default to `"flex_v{version}"`.
""",
    ),
    "version": attr.string(
        doc = "A supported version of Flex.",
        default = DEFAULT_VERSION,
        values = sorted(VERSION_URLS),
    ),
    "extra_copts": attr.string_list(
        doc = "Additional C compiler options to use when building Flex.",
    ),
}

flex_repository_ext = module_extension(
    implementation = _flex_repository_ext,
    doc = """
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
""",
    tag_classes = {
        "repository": tag_class(
            attrs = _REPOSITORY_TAG_ATTRS,
        ),
    },
)
