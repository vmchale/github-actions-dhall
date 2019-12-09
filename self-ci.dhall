let dhallCi =
      ./dhall-ci.dhall sha256:29a496666d5510f69e614d86f44ffb6564d5d0fa5531eb534bf820d64bbbc34f

in    dhallCi.dhallCi
        [ "haskell-ci.dhall"
        , "example.dhall"
        , "self-ci.dhall"
        , "ats-ci.dhall"
        , "toml-ci.dhall"
        ]
    : dhallCi.CI.Type
