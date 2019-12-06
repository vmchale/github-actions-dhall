let haskellCi = ./haskell-ci.dhall

let concatMap =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatMap

let dhallInstall =
      haskellCi.BuildStep.Name
        { name = "Install dhall"
        , run =
            ''
            cabal update
            cabal install dhall
            ''
        }

let dhallCache =
      haskellCi.BuildStep.UseCache
        { uses = "actions/cache@v1"
        , with =
            haskellCi.CacheCfg::{
            , path = "~/.cabal/bin"
            , key = "\${{ runner.os }}-cabal-\${{ hashFiles('**/*.log') }}"
            }
        }

let checkDhall =
        λ(dhalls : List Text)
      → haskellCi.BuildStep.Name
          { name = "Check Dhall"
          , run =
                  ''
                  export PATH=$HOME/.cabal/bin:$PATH
                  ''
              ++  concatMap
                    Text
                    (   λ(d : Text)
                      → ''
                        dhall --file ${d}
                        ''
                    )
                    dhalls
          }

let dhallCi =
        λ(dhalls : List Text)
      →   haskellCi.generalCi
            [ haskellCi.checkout
            , haskellCi.haskellEnv haskellCi.defaultEnv
            , dhallCache
            , dhallInstall
            , checkDhall dhalls
            ]
            (None haskellCi.DhallMatrix)
        : haskellCi.CI.Type

in  { dhallInstall = dhallInstall
    , dhallCi = dhallCi
    , checkDhall = checkDhall
    , CI = haskellCi.CI
    }
