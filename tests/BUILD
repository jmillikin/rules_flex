load("//:flex.bzl", "flex_lexer")

flex_lexer(
    name = "hello_c",
    src = "hello.l",
)

cc_binary(
    name = "hello_c_bin",
    srcs = [":hello_c"],
)

flex_lexer(
    name = "hello_cc",
    src = "hello.l",
    language = "c++",
)

cc_binary(
    name = "hello_cc_bin",
    srcs = [":hello_cc"],
)
