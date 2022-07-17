
  Asv = do ->

    # ASCII Separated Values

    { char, capitalize, lf } = Str
    { fieldnames, values } = FieldSet
    { map } = List

    # https://en.wikipedia.org/wiki/C0_and_C1_control_codes#Field_separators

    separators =

      unit: char 31
      record: char 30
      group: 29
      file: 28

    replace-crlf = (.replace /\r\n/g, separators.record)
    replace-lf = (.replace /\n/g, separators.record)

    text-as-records = (str) -> str |> replace-crlf |> replace-lf
    records-as-text = (records-str, separator = lf) -> records-str |> (.split separators.record) |> (.join separator)

    records-as-list = (records-str) -> records-str.split separators.record

    record-as-list = (record-str) -> record-str.split separators.unit

    text-as-lines = (str) -> str |> text-as-records |> records-as-list

    lines-as-text = (lines, separator = lf) -> lines.join separator

    list-as-record = (.join separators.unit)

    list-as-records = (.join separators.record)

    fieldset-values-as-record = (fieldset) -> fieldset |> values |> list-as-record

    fieldsets-values-as-record-list = (fieldsets) -> fieldsets |> map _ , fieldset-values-as-record

    fieldsets-as-records = (fieldsets) ->

      return records [] if fieldsets.length is 0

      record-list = fieldsets-values-as-record-list fieldsets

      [ fieldsets.0 |> fieldnames |> list-as-record ] ++ (record-list |> list-as-records)

    {
      separators,
      text-as-records, records-as-text,
      list-as-records, records-as-list,
      list-as-record, record-as-list,
      text-as-lines, lines-as-text,

      fieldsets-as-records, fieldset-values-as-record, fieldsets-values-as-record-list
    }
