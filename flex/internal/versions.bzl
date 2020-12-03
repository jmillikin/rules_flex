# Copyright 2019 the rules_flex authors.
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

_GITHUB_MIRRORS = [
    "https://github.com/westes/flex/releases/download/",
]

def _github_urls(filename):
    return [m + filename for m in _GITHUB_MIRRORS]

_SOURCEFORGE_MIRRORS = [
    "https://sourceforge.net/projects/flex/files/",
]

def _sourceforge_urls(filename):
    return [m + filename for m in _SOURCEFORGE_MIRRORS]

DEFAULT_VERSION = "2.6.4"

VERSION_URLS = {
    "2.6.4": {
        "urls": _github_urls("v2.6.4/flex-2.6.4.tar.gz"),
        "sha256": "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995",
    },
    "2.6.3": {
        "urls": _github_urls("v2.6.3/flex-2.6.3.tar.gz"),
        "sha256": "68b2742233e747c462f781462a2a1e299dc6207401dac8f0bbb316f48565c2aa",
    },
    "2.6.2": {
        "urls": _github_urls("v2.6.2/flex-2.6.2.tar.gz"),
        "sha256": "9a01437a1155c799b7dc2508620564ef806ba66250c36bf5f9034b1c207cb2c9",
    },
    "2.6.1": {
        "urls": _github_urls("v2.6.1/flex-2.6.1.tar.xz"),
        "sha256": "2c7a412c1640e094cb058d9b2fe39d450186e09574bebb7aa28f783e3799103f",
    },
    "2.6.0": {
        "urls": _sourceforge_urls("flex-2.6.0.tar.xz"),
        "sha256": "d39b15a856906997ced252d76e9bfe2425d7503c6ed811669665627b248e4c73",
    },
    "2.5.39": {
        "urls": _sourceforge_urls("flex-2.5.39.tar.xz"),
        "sha256": "c988bb3ab340aaba16df5a54ab98bb4760599975375c8ac9388a078b7f27e9e8",
    },
    "2.5.38": {
        "urls": _sourceforge_urls("flex-2.5.38.tar.xz"),
        "sha256": "3621e0217f6c2088411e5b6fd9f2d83f2fbf014dcdf24e80680f66e6dd93729c",
    },
    "2.5.37": {
        "urls": _sourceforge_urls("flex-2.5.37.tar.bz2"),
        "sha256": "17aa7b4ebf19a13bc2dff4115b416365c95f090061539a932a68092349ac052a",
    },
    "2.5.36": {
        "urls": _sourceforge_urls("flex-2.5.36.tar.bz2"),
        "sha256": "c466e68bbbb0a7884301ba257376f98197254543799690b671b1ac2130645d55",
    },
}

def check_version(version):
    if version not in VERSION_URLS:
        fail("Flex version {} not supported by rules_flex.".format(repr(version)))
