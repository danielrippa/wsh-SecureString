
  PowerShell = do ->

    { shell-quote: quote, shell-pipe: pipe, executable } = Shell
    { new-tempfile, get-content } = TextFile
    { text-encoding } = Str

    powershell = (working-folder, output-encoding = text-encoding.ascii, discard-output = no) ->

      pwsh = executable 'powershell.exe', void, working-folder, output-encoding, discard-output

      output = new-tempfile! #TODO: Fix

      (command) ->

        cmd = pwsh "-NoProfile -ExecutionPolicy ByPass -OutputFormat Text Invoke-Command -Command #command | Out-File -FilePath #{ output.file-path } -Encoding ASCII"
        cmd.stdout = get-content output.file-path

        cmd

    sb-arg = (arg) -> if (typeof! arg) is 'String' then quote arg else arg

    sb-arglist = (args) -> [ (sb-arg arg) for arg in args ]

    sb-args = (args) -> if args is void then '' else " -ArgumentList #{ sb-arglist args }"

    script-block = (block, working-folder, output-encoding, discard-output = yes) ->

      ps = powershell working-folder, output-encoding, discard-output

      -> ps "{ #block }#{ sb-args [ (argument) for argument in arguments ] }"

    script = (lines, working-folder, output-encoding, discard-output) ->

      sb = script-block lines.join ' ; ', working-folder, output-encoding, discard-output

      -> sb.apply null, arguments

    {
      powershell, script-block, script
      quote, pipe
    }