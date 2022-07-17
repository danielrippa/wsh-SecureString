
  Shell = do ->

    { fail } = Wsh
    { new-tempfile, text-encoding } = TextFile
    { file-exists, folder-exists } = FileSystem
    { quote } = Str

    shell = -> new ActiveXObject 'WScript.Shell'

    exec = -> shell!exec it

      # returns a WshScriptExec

      # https://www.vbsedit.com/html/f3358e96-3d5a-46c2-b43b-3107e586736e.asp

      #  .ExitCode
      #  .ProcessID
      #  .Status
      #  .StdErr
      #  .StdIn
      #  .StdOut

      #  .Terminate!

    rundll = (dll, fn) -> new-exec "rundll32 #dll,#fn"

    script = (script-path, computer) ->

      CreateObject 'WSHController'
        return ..CreateScript script-path, computer

      # returns a WshRemote

      # https://www.vbsedit.com/html/f9f0e5da-824d-4cde-a67b-02108178ee45.asp

      #  .Error
      #  .Status

      #  .Execute
      #  .Terminate

      #  .End event
      #  .Error event
      #  .Start event

      #  To use events in JScript see WScript.ConnectObject and WScript.DisconnectObject
      #  https://www.vbsedit.com/html/fffd2ade-9fa7-42e8-a0c9-a6a7e631b378.asp

      #  .Execute!
      #  .Terminate!

    run = (command, working-folder, output-encoding = text-encoding.unicode, discard-output = yes) ->

      stdout = new-tempfile!
      stderr = new-tempfile!

      command-line = "#command > #{ quote stdout.file-path } 2> #{ quote stderr.file-path }"

      new ActiveXObject 'WScript.Shell'

        ..CurrentDirectory = working-folder \
          unless working-folder is void

        status = ..Run command-line, 0, yes

      get-content = -> it.get-content discard-output

      output =

        stdout: get-content stdout
        stderr: get-content stderr

      { status, command, command-line } <<< output

    cmd = (command, working-folder, output-encoding, discard-output = yes) ->

      run "%comspec% /c #command", working-folder, output-encoding, discard-output

    find-executable = (executable) -> { status } = cmd "where #executable" ; status is 0

    shell-quote = -> quote quote quote it

    shell-escape = -> "^#it"

    shell-pipe = shell-escape '|'

    fail-not-found = !-> fail "Executable '#it' not found."

    executable = (name, path, working-folder, output-encoding, discard-output) ->

      executable-path = do ->

        if path is void

          if find-executable name

            name

          else

            fail-not-found name \
              if not file-exists name

            executable

        else

          fail "Folder '#path' of executable '#name' not found." \
            if not folder-exists path

          path = "#path#slash#name"

          fail-not-found path \
            if not file-exists path

          path

      (args) ->

        run "#executable-path #args", working-folder, output-encoding, discard-output

    wsf-name = (name) ->

      index = name.index-of '.'

      if index is -1
        "#name.wsf"
      else
        name

    wsf = (name, path, timeout, working-folder, output-encoding, discard-output) ->

      validated-wsf-path = validated-executable-path (wsf-name name), path

      timeout = if timeout isnt void
        "/t:#timeout"
      else
        ""

      encoding = if output-encoding is text-encoding.unicode
        "/u"
      else
        ""

      (args) ->

        cmd "cscript #timeout #encoding /b /nologo #validated-wsf-path #args", working-folder, output-encoding, discard-output

    {
      exec, run, cmd, find-executable, rundll, executable, wsf,
      shell-quote, shell-escape, shell-pipe
    }