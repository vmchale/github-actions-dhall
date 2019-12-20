let dhallCi =
      ./dhall-ci.dhall sha256:71ec2d1e0e3531ee2a5696120c84c46379e202c05528b7aef2d73a5ecf13c601

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
      ⫽ { on = [ dhallCi.Event.push ] }
    : dhallCi.CI
