let dhallCi =
      ./dhall-ci.dhall sha256:c5b9fca54c2375479bbf40905a6100f01c4061211eb115f14ca0f62cddd12543

in    dhallCi.dhallCi
        [ "haskell-ci.dhall"
        , "example.dhall"
        , "self-ci.dhall"
        , "ats-ci.dhall"
        , "toml-ci.dhall"
        , "self-ci.dhall"
        ]
    : dhallCi.CI.Type
