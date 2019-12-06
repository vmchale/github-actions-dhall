let haskellCi = ./haskell-ci.dhall

let concatMap =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatMap
let dhallInstall =
      haskellCi.BuildStep.Name
        { name = "Install dhall"
        , run =
            ''
            cabal install dhall
            export PATH=$HOME/.cabal/bin:$PATH
            ''
        }

let checkDhall =
        λ(dhalls : List Text)
      → haskellCi.BuildStep.Name
        { name = "Check Dhall"
        , run = concatMap Text (λ(d : Text) → "dhall --file ${d}\n") dhalls }

in    haskellCi.generalCi
        [ haskellCi.checkout
        , haskellCi.haskellEnv haskellCi.defaultEnv
        , dhallInstall
        , checkDhall [ "haskell-ci.dhall", "example.dhall", "self-ci.dhall" ]
        ]
        (None haskellCi.DhallMatrix)
    : haskellCi.CI.Type
