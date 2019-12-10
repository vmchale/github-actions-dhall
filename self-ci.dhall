let dhallCi =
      ./dhall-ci.dhall sha256:6468d335d3d9ae593ca92c3cf08ecbf07571e662272608c3e98ea19ae7c8dd58

in    dhallCi.dhallSteps
        [ dhallCi.dhallYamlInstall
        , dhallCi.checkDhall
            [ "haskell-ci.dhall"
            , "ats-ci.dhall"
            , "toml-ci.dhall"
            , "self-ci.dhall"
            , "python-ci.dhall"
            , "yaml-ci.dhall"
            ]
        , dhallCi.checkDhallYaml [ "self-ci.dhall", "example.dhall" ]
        ]
    : dhallCi.CI
