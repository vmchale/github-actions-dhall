let dhallCi =
      ./dhall-ci.dhall sha256:af279cc8b83d041c03553a62a06ce0e4f64a0d08bd1ed1e0f4f93735fe728f7e

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
