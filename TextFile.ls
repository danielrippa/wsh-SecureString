
  TextFile = do ->

    { get-tempfile-path, file-exists, delete-file } = FileSystem
    { text-as-lines, lines-as-text } = Asv
    { lf, text-encoding } = Str

    io-mode = reading: 1, writing: 2, appending: 8

    new ActiveXObject 'Scripting.FileSystemObject'

      text-stream = (filename, mode, create = no, encoding = text-encoding.ascii) -> ..OpenTextFile filename, mode, create, encoding

    use-stream = (stream, fn) !-> try result = fn stream ; stream.Close! ; return result

    readable = (filename, encoding) -> text-stream filename, io-mode.reading, no, encoding
    writeable = (filename, encoding, appending = no, create = yes) -> text-stream filename, (io-mode => if appending then ..appending else ..writing), create, encoding

    get-content = (filename, encoding) -> use-stream (readable filename, encoding), (.ReadAll!)
    set-content = (filename, content, encoding, appending = no, create = yes) !-> use-stream (writeable filename, encoding, appending, create), (.Write content)
    add-content = (filename, content, encoding) !-> set-content filename, content, encoding, yes

    get-lines = (filename, encoding) -> text-as-lines get-content filename, encoding
    set-lines = (filename, lines, encoding, separator = lf, appending, create) !-> set-content filename, (lines.join separator), encoding, appending, create
    add-lines = (filename, lines, encoding, separator) -> add-content filename, lines, encoding, separator

    new-tempfile = ->

      file-path = get-tempfile-path!

      remove = !->

        if file-exists file-path

          delete-file file-path

      read = (discard = yes) ->

        if file-exists file-path

          content = get-content file-path

          remove! if discard

        content

      { file-path, remove } <<< { get-content: read }

    {
      text-encoding,
      get-content, set-content, add-content,
      get-lines, set-lines, add-lines,
      new-tempfile
    }