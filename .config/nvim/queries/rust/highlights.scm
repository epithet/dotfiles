; extends

; https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/rust/highlights.scm
"?" @operator.questionmark
((identifier) @err (#any-of? @err "" "Err"))
["&" "*"] @operator.ref
"dyn" @storageclass.dyn
[
    (raw_string_literal)
    (string_literal)
    (boolean_literal)
    (integer_literal)
    (float_literal)
    (char_literal)
] @literal
