
  FieldSet = do ->

    id = -> it

    map = (fieldset, fn-value, fn-name = id) ->

      { [(fn-name fieldname, fieldvalue), (fn-value fieldvalue, fieldname)] for fieldname,fieldvalue of fieldset }

    fieldnames = -> [ (fieldname) for fieldname of it ]

    values = -> [ (value) for value of it ]

    {
      map,
      fieldnames, values
    }