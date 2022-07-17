
  Args = do ->

    { fail, errln, script-name } = Wsh
    { dasherize, camelize } = Str

    WScript

      ..Arguments

        ..Named

          param = ->

            result = void

            if ..Exists it

              result = ..Item it
              if result is void
                result = true

            result

        ..Unnamed

          arg = -> ..Item it
          argc = ..Count

    argv = [ (arg index) for index til argc ]

    get-args = (unnamed-params-descriptors = [], named-params-descriptors = [], optional-params-descriptors = [], param-descriptions = {}) ->

      [ optional-reference-names, optional-references ] = do ->

        names = [] ; references = {}

        for descriptor in optional-params-descriptors

          [ name, value ] = descriptor.split '='

          names[*] = name
          references[name] = value

        [ names, references ]

      [ unnamed-references, unnamed-reference-indexes, unnamed-default-values, mandatory-count ] = do ->

        references = [] ; indexes = [] ; default-values = [] ; mandatory-index = -1

        optionals-declared-so-far = []

        for descriptor, descriptor-index in unnamed-params-descriptors

          optional = no

          unnamed-names = descriptor.split '|'

          default-value = void

          for reference-name in unnamed-names

            references[*] = reference-name
            indexes[*] = descriptor-index

            if reference-name in optional-reference-names

              optional = yes

              default-value = optional-references[reference-name]

            default-values[*] = default-value

          if not optional

            mandatory-index = descriptor-index

            if optionals-declared-so-far.length isnt 0

              errln "Cannot declare '#descriptor' as mandatory when at least one parameter was declared as optional before."
              fail "Prior parameter(s) declared as optional: #{ optionals-declared-so-far.join ', ' }."

          else

            optionals-declared-so-far[*] = descriptor

        [ references, indexes, default-values, mandatory-index ]

      [ named-param-names, named-references, named-default-values ] = do ->

        param-names = [] ; references = [] ; default-values = []

        for descriptor in named-params-descriptors

          [ param-name, value-name ] = descriptor.split ':'

          param-names[*] = param-name

          default-value = void

          references[*] = param-name

          if value-name isnt void

            references[*] = value-name

            default-value = optional-references[value-name]

          default-values[*] = default-value

        [ param-names, references, default-values ]

      reference-names = unnamed-references ++ named-references

      reference-exists = (reference-name) -> reference-name in reference-names

      do !->

        for reference-name, index in optional-reference-names

          unless reference-exists reference-name

            fail "Invalid reference '#reference-name' in optional value declaration '#{ optional-params-descriptors[index] }'."

      usage = do ->

        descriptions = []

        for reference-name, description of param-descriptions

          name = dasherize reference-name

          unless reference-exists name

            fail "Invalid reference '#name' with reference description '#description'."

          if descriptions.length is 0
            descriptions[*] = ''
            descriptions[*] = 'Where:'

          descriptions[*] = "  #name: #description"

        param-names = do ->

          line = [ script-name ]

          for descriptor in unnamed-params-descriptors

            bracketed = no

            line[*] = if bracketed then brackets descriptor else descriptor

          line.join ' '

        <[ Usage: ]> ++ [] ++ param-names ++ descriptions ++ []

      show-usage = !-> for line in usage => errln line

      result = {}

      if param '?'
        show-usage!
        fail!

      if argc <= mandatory-count

        errln "Not enough parameters.\n"
        show-usage!
        fail!

      for name, reference-index in unnamed-references

        name = camelize name

        index = unnamed-reference-indexes[reference-index]

        if index < argc

          result[name] = arg index

        else

          result[name] = unnamed-default-values[reference-index]

      for name, index in named-param-names

        name = camelize name

        value = param name

        if value is void

          value = named-default-values[index]

        if value is void

          value = false

        result[name] = value

      result

    {
      arg, argc, argv, get-args
    }