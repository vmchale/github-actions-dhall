let dhallCi = ./dhall-ci.dhall sha256:9e13074986753db36ff04f79acf01190def32727e4548ace2391a31b54c3658d

in    dhallCi.dhallCi [ "haskell-ci.dhall", "example.dhall", "self-ci.dhall" ]
    : dhallCi.CI.Type
