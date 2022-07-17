
  Str = do ->

    text-encoding = system-default: -2, unicode: -1, ascii: 0

    cr = '\r'
    lf = '\n'

    crlf = "#cr#lf"

    char = -> String.from-char-code it

    concat = (str, separator = '') -> str.join separator

    split = (str, separator = '') -> str.split separator

    str-as-words = (str) ->

      switch str.length

        | 0 => []
        | otherwise => str.split /[ ]+/

    repeat = (value, count) -> new Array count + 1 .join value

    lcase = (.to-lower-case!)
    ucase = (.to-upper-case!)

    capitalize-word = (str) ->

      * ucase str.char-at 0
        str.slice 1
      |> chars-as-list

    map = (list, fn) -> [ (fn item) for item in list ]

    capitalize = (str) ->

      str

        |> str-as-words
        |> map _ , capitalize-word
        |> concat _ , ' '

    affix = (stem, prefix = '', suffix = '') -> "#prefix#stem#suffix"

    prepend = (stem, prefix) -> affix stem, prefix
    append  = (stem, suffix) -> affix stem, void, suffix

    padl = (value, count, padding = '0') -> prefix = repeat padding, count ; prepend value, prefix |> (.slice -count)
    padr = (value, count, padding = ' ') -> suffix = repeat padding, count ; append  value, suffix |> (.slice 0, count)

    quote-kind =

      single: "'"
      double: '"'

    quote = (stem, adfix = quote-kind.double) -> affix stem, adfix, adfix

    camel = -> ucase &1 ? ''

    camelize = (.replace /[-_]+(.)?/g, camel)

    dash-lower-upper = (, lower, upper) -> "#{ lower }-#{ if upper.length > 1 then upper else lcase upper }"

    dash-upper = (, upper) -> if upper.length > 1 then "#upper-" else lcase upper

    replace-upper-lower = (.replace /([^-A-Z])([A-Z]+)/g, dash-lower-upper)

    replace-upper = (.replace /^([A-Z]+)/, dash-upper)

    dasherize = (str) -> str |> replace-upper-lower |> replace-upper

    trim = (.replace /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '')

    contains = (one, another) -> lcase one |> (.index-of lcase another) |> -> it > -1

    {
      text-encoding,
      cr, lf, crlf,
      char,
      concat, split,
      str-as-words,
      repeat,
      lcase, ucase,
      capitalize, capitalize-word,
      affix, prepend, append,
      padl, padr,
      quote-kind, quote,
      camelize, dasherize,
      trim,
      contains
    }