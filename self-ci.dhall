let dhallCi =
      ./dhall-ci.dhall sha256:2a8e60c47ac16cfe0bd02d9a348b175b841095e62918448ce9b3bf65fe8cfe78

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
              , "futhark-ci.dhall"
              ]
          , dhallCi.checkDhallYaml [ "self-ci.dhall", "example.dhall" ]
          ]
      ⫽ { on = [ dhallCi.Event.push ] }
    : dhallCi.CI
