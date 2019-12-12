let dhallCi =
      ./dhall-ci.dhall sha256:50c5c1017d3661f47c915e0c64e9735773dc4e22770c07f46bae168a2dffc44d

in      dhallCi.dhallSteps
          [ dhallCi.dhallYamlInstall
          , dhallCi.checkDhall
              [ "haskell-ci.dhall"
              , "ats-ci.dhall"
              , "toml-ci.dhall"
              , "self-ci.dhall"
              , "python-ci.dhall"
              , "yaml-ci.dhall"
              , "egison-ci.dhall"
              ]
          , dhallCi.checkDhallYaml [ "self-ci.dhall", "example.dhall" ]
          ]
      ⫽ { on = [ dhallCi.printEvent dhallCi.Event.Push ] }
    : dhallCi.CI
