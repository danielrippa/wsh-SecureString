
  Wsh = do ->

    WScript

      script-host = ..FullName.slice -11 .slice 0 7

      script-name = ..ScriptName.split '.' .0

      sleep = -> ..Sleep it * 1000

      exit = !-> ..Quit it

      [ stdout, stderr ] = do ->

        std = (stream) -> -> for arg in arguments => ..["Std#stream"].Write arg

        [ (std name) for name in <[ Out Err ]> ]

      fail = (message, errorlevel = 1) !->

        if message isnt void then stderr message
        exit errorlevel

      [ stdln, errln ] = do ->

        writeln = (write) -> -> write [ (String arg) for arg in arguments ].join ' ' ; write '\n'

        [ (writeln stream) for stream in [ stdout, stderr ] ]

      echo = stdln

    get-stdin = ->

      stdin = ''

      loop

        WScript.StdIn

          break if not ..AtEndOfStream

          stdin = stdin + ..ReadAll!

      stdin

    kv = !-> for k,v of it => echo "#k: #v"

    {
      script-host, script-name,
      sleep, exit, fail,
      stdout, stderr,
      echo, stdln, errln, kv,
      get-stdin
    }
