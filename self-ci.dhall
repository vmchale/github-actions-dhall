let dhallCi =
      ./dhall-ci.dhall sha256:b8c4129e6c75258d4dd3319a7c536b769d00a3e7bacb73c67555145f43ccc351

in    dhallCi.dhallCi
        [ "haskell-ci.dhall", "example.dhall", "self-ci.dhall", "ats-ci.dhall" ]
    : dhallCi.CI.Type
