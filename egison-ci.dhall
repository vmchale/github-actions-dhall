let haskellCi =
      ./haskell-ci.dhall sha256:0436a5c08f98e083bfb147330ff273f2b182a9e695e0e67441c0f22c3bf4dc4d

let concatMap =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatMap sha256:7a0b0b99643de69d6f94ba49441cd0fa0507cbdfa8ace0295f16097af37e226f

let egiInstall =
      haskellCi.BuildStep.Name
        { name = "Install egison"
        , run =
            ''
            cabal update
            cabal install egison
            ''
        }

let checkEgi =
        λ(egis : List Text)
      → haskellCi.BuildStep.Name
          { name = "Check Egison files"
          , run =
                  ''
                  export PATH=$HOME/.cabal/bin:$PATH
                  ''
              ++  concatMap
                    Text
                    (   λ(d : Text)
                      → ''
                        egison --test ${d}
                        ''
                    )
                    egis
          }

let egiSteps =
        λ(steps : List haskellCi.BuildStep)
      →     haskellCi.ciNoMatrix
              (   [ haskellCi.checkout
                  , haskellCi.haskellEnv haskellCi.latestEnv
                  , egiInstall
                  ]
                # steps
              )
          ⫽ { name = "Egison CI" }
        : haskellCi.CI.Type

let egiCi = λ(egis : List Text) → egiSteps [ checkEgi egis ] : haskellCi.CI.Type

in  { egiInstall = egiInstall
    , egiCi = egiCi
    , checkEgi = checkEgi
    , egiSteps = egiSteps
    , CI = haskellCi.CI.Type
    , BuildStep = haskellCi.BuildStep
    , Event = haskellCi.Event
    }
