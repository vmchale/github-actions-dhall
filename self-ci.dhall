let dhallCi =
      ./dhall-ci.dhall sha256:339271a457453bad1b153f34600305a13dd474cb17e69fbcdae1fe0ef92c357f

in    dhallCi.dhallCi
        [ "haskell-ci.dhall"
        , "example.dhall"
        , "self-ci.dhall"
        , "ats-ci.dhall"
        , "toml-ci.dhall"
        ]
    : dhallCi.CI.Type
