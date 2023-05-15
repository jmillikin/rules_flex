workspace(name = "rules_flex")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_m4",
    sha256 = "10ce41f150ccfbfddc9d2394ee680eb984dc8a3dfea613afd013cfb22ea7445c",
    urls = ["https://github.com/jmillikin/rules_m4/releases/download/v0.2.3/rules_m4-v0.2.3.tar.xz"],
)

load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")

m4_register_toolchains()

load("//flex:flex.bzl", "flex_register_toolchains", "flex_repository")

# buildifier: disable=bzl-visibility
load("//flex/internal:testutil.bzl", "rules_flex_testutil")

# buildifier: disable=bzl-visibility
load("//flex/internal:versions.bzl", "VERSION_URLS")

rules_flex_testutil(name = "rules_flex_testutil")

flex_register_toolchains()

[flex_repository(
    name = "flex_v" + version,
    version = version,
) for version in VERSION_URLS]

http_archive(
    name = "com_google_googletest",
    sha256 = "81964fe578e9bd7c94dfdb09c8e4d6e6759e19967e397dbea48d1c10e45d0df2",
    strip_prefix = "googletest-release-1.12.1",
    urls = ["https://github.com/google/googletest/archive/release-1.12.1.tar.gz"],
)
