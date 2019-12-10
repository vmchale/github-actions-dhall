let dhallCi =
      ./dhall-ci.dhall sha256:8923d42348505bcd1ffe646807ef442fd0c39fad9060df830bf41d25b7918145

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
