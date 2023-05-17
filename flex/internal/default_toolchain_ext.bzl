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

"""Adds a default `flex_toolchain_repository` for a bzlmod-enabled workspace."""

load("//flex/internal:versions.bzl", "DEFAULT_VERSION")
load("//flex/rules:flex_repository.bzl", "flex_repository")
load(
    "//flex/rules:flex_toolchain_repository.bzl",
    "flex_toolchain_repository",
)

def _default_toolchain_ext(module_ctx):
    flex_repo_name = "flex_v{}".format(DEFAULT_VERSION)
    flex_repository(
        name = flex_repo_name,
        version = DEFAULT_VERSION,
    )
    flex_toolchain_repository(
        name = "flex",
        flex_repository = "@" + flex_repo_name,
    )
    return module_ctx.extension_metadata(
        root_module_direct_deps = ["flex"],
        root_module_direct_dev_deps = [],
    )

default_toolchain_ext = module_extension(_default_toolchain_ext)
