filegroup(
    name = "flex_lexer_h",
    srcs = ["src/FlexLexer.h"],
    visibility = ["@io_bazel_rules_flex//flex/toolchains:__pkg__"],
)

cc_library(
    name = "flex_lib",
    srcs = glob(
        [
            "src/*.c",
            "src/*.h",
        ],
        exclude = ["src/lib*.c"],
    ),
    copts = [
        "-DHAVE_ASSERT_H",
        "-DHAVE_LIMITS_H",
        "-DHAVE_NETINET_IN_H",
        '-DVERSION="{VERSION}"',
        '-DM4="/bin/false"',
    ],
    features = ["no_copts_tokenization"],
    visibility = ["//bin:__pkg__"],
)
