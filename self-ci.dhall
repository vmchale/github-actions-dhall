let dhallCi = ./dhall-ci.dhall

in    dhallCi.dhallCi [ "haskell-ci.dhall", "example.dhall", "self-ci.dhall" ]
    : dhallCi.CI.Type
