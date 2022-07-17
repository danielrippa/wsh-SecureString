
  FileSystem = do ->

    slash = '\\'

    fso = new ActiveXObject 'Scripting.FileSystemObject'

      get-special-folder = -> ..GetSpecialFolder it

      delete-file = -> try ..DeleteFile it ; return yes catch => return no
      delete-folder = -> try ..DeleteFolder it ; return yes catch => return no

      file-exists = -> ..FileExists it

      folder-exists = -> ..FolderExists it

    get-special-folder-path = -> get-special-folder it .Path

    special-folder-types = windows: 0, system: 1, temporary: 2

    get-tempfile-path = -> "#{ get-special-folder-path special-folder-types.temporary }#slash#{ fso.GetTempName! }"

    {
      fso,
      slash,
      special-folder-types,
      get-special-folder, get-special-folder-path,
      get-tempfile-path,
      file-exists, folder-exists,
      delete-file, delete-folder
    }