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

"""Definition of the `flex` build rule."""

load(
    "//flex/internal:flex_action.bzl",
    "FLEX_ACTION_TOOLCHAINS",
    "flex_action",
    "flex_action_attrs",
)

def _flex(ctx):
    result = flex_action(ctx)
    return DefaultInfo(files = result.outs)

flex = rule(
    implementation = _flex,
    doc = """Generate C/C++ source code for a Flex lexical analyzer.

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
""",
    attrs = flex_action_attrs({}),
    toolchains = FLEX_ACTION_TOOLCHAINS,
)
