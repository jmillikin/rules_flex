load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

bzl_library(
    name = "rules_flex_bzl_srcs",
    srcs = ["//flex:bzl_srcs"],
)

stardoc(
    name = "rules_flex_raw_md",
    out = "rules_flex_raw.md",
    input = "rules_flex_md.bzl",
    deps = [":rules_flex_bzl_srcs"],
)

# https://github.com/bazelbuild/stardoc/issues/78
genrule(
    name = "rules_flex_md",
    srcs = [":rules_flex_raw.md"],
    outs = ["rules_flex.md"],
    cmd = """
sed \\
  -e 's/C or C++ mode:/C or C++ mode:<ul>/g' \\
  -e 's/  - \\([^-]*\\)  /<li>\\1<\\/li>  /' \\
  -e 's/  - \\([^-]*\\)  /<li>\\1<\\/li>  /' \\
  -e 's/<br><br>The C++ output/<\\/ul>The C++ output/g' \\
  $< > $@
""",
)

filegroup(
    name = "stardoc_outputs",
    srcs = [":rules_flex.md"],
    visibility = ["//:__subpackages__"],
)
