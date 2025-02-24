load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

stardoc(
    name = "flex_md",
    out = "flex.md",
    header_template = ":header.vm",
    input = "//flex:flex_bzl",
    deps = ["//flex:bzl_srcs"],
)

stardoc(
    name = "flex_repository_ext_md",
    out = "flex_repository_ext.md",
    header_template = ":empty.vm",
    input = "//flex/extensions:flex_repository_ext_bzl",
    deps = ["//flex:bzl_srcs"],
)

# https://github.com/bazelbuild/stardoc/issues/78
genrule(
    name = "rules_flex_md",
    srcs = [
        ":flex_md",
        ":flex_repository_ext_md",
    ],
    outs = ["rules_flex.md"],
    cmd = """
cat $(SRCS) | sed \\
  -e 's/C or C++ mode:/C or C++ mode:<ul>/g' \\
  -e 's/  - \\([^-]*\\)  /<li>\\1<\\/li>  /' \\
  -e 's/  - \\([^-]*\\)  /<li>\\1<\\/li>  /' \\
  -e 's/<br><br>The C++ output/<\\/ul>The C++ output/g' \\
  > $@
""",
)

filegroup(
    name = "stardoc_outputs",
    srcs = [":rules_flex_md"],
    visibility = ["//:__subpackages__"],
)
