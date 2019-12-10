let dhallCi =
      ./dhall-ci.dhall sha256:b98935ce728983458769efb00679ef80f732b1b64154e1ae8cc841c82f8a0d88

in    dhallCi.dhallCi
        [ "haskell-ci.dhall"
        , "example.dhall"
        , "self-ci.dhall"
        , "ats-ci.dhall"
        , "toml-ci.dhall"
        , "self-ci.dhall"
        , "python-ci.dhall"
        , "yaml-ci.dhall"
        ]
    : dhallCi.CI
