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

"""Helpers for testing rules_flex in a bzlmod-enabled workspace."""

load("//flex/internal:versions.bzl", "VERSION_URLS")
load("//flex/rules:flex_repository.bzl", "flex_repository")
load(":testutil.bzl", "rules_flex_testutil")

def _rules_flex_testutil_ext(_module_ctx):
    rules_flex_testutil(name = "rules_flex_testutil")
    for version in VERSION_URLS:
        flex_repository(
            name = "flex_v{}".format(version),
            version = version,
        )

rules_flex_testutil_ext = module_extension(_rules_flex_testutil_ext)
