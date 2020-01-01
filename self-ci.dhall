let dhallCi =
      ./dhall-ci.dhall sha256:0ef11bbce3ff55ed7c0320be282e4a547844539b0a7de3c54eb3fdec84090c8b

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
