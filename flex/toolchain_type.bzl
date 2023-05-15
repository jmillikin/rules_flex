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

"""Helpers for depending on Flex as a toolchain."""

FLEX_TOOLCHAIN_TYPE = "@rules_flex//flex:toolchain_type"

def flex_toolchain(ctx):
    """Returns the current [`FlexToolchainInfo`](#FlexToolchainInfo).

    Args:
        ctx: A rule context, where the rule has a toolchain dependency
          on [`FLEX_TOOLCHAIN_TYPE`](#FLEX_TOOLCHAIN_TYPE).

    Returns:
        A [`FlexToolchainInfo`](#FlexToolchainInfo).
    """
    return ctx.toolchains[FLEX_TOOLCHAIN_TYPE].flex_toolchain
