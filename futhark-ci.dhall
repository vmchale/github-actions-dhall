let haskellCi =
      ./haskell-ci.dhall sha256:2de95c8bd086c21660c2849dfe2d9af72e675bed44396159d647292d329a20e4

let concatMap =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatMap sha256:7a0b0b99643de69d6f94ba49441cd0fa0507cbdfa8ace0295f16097af37e226f

let futharkInstall =
      haskellCi.BuildStep.Name
        { name = "Install Futhark"
        , run =
            ''
            cabal update
            cd "$(mktemp -d /tmp/futhark-XXX)"
            cabal install futhark --constraint='megaparsec < 8.0.0'
            ''
        }

let futharkPkgDeps =
      haskellCi.BuildStep.Name
        { name = "Install Futhark package dependencies"
        , run =
            ''
            futhark pkg sync
            ''
        }

let checkFuthark =
        λ(futs : List Text)
      → haskellCi.BuildStep.Name
          { name = "Check Futhark"
          , run =
                  ''
                  export PATH=$HOME/.cabal/bin:$PATH
                  ''
              ++  concatMap
                    Text
                    (   λ(d : Text)
                      → ''
                        futhark check ${d}
                        ''
                    )
                    futs
          }

let futharkSteps =
        λ(steps : List haskellCi.BuildStep)
      →   haskellCi.ciNoMatrix
            (   [ haskellCi.checkout
                , haskellCi.haskellEnv haskellCi.latestEnv
                , futharkInstall
                ]
              # steps
            )
        ⫽ { name = "Futhark CI" }

let futharkCi =
        λ(futs : List Text)
      → futharkSteps [ checkFuthark futs ] : haskellCi.CI.Type

in  { CI = haskellCi.CI.Type
    , futharkSteps = futharkSteps
    , checkFuthark = checkFuthark
    , futharkCi = futharkCi
    , futharkPkgDeps = futharkPkgDeps
    }
