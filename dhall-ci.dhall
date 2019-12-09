let haskellCi =
      ./haskell-ci.dhall sha256:864399147f8a2161eadd867f6dc22da794a25deae9a375fc3c98715960b4c07e

let concatMap =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatMap sha256:7a0b0b99643de69d6f94ba49441cd0fa0507cbdfa8ace0295f16097af37e226f

let dhallInstall =
      haskellCi.BuildStep.Name
        { name = "Install dhall"
        , run =
            ''
            cabal update
            cabal install dhall
            ''
        }

let dhallYamlInstall =
      haskellCi.BuildStep.Name
        { name = "Install dhall"
        , run =
            ''
            cabal update
            cabal install dhall-json
            ''
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
            , dhallInstall
            , checkDhall dhalls
            ]
            (None haskellCi.DhallMatrix.Type)
        : haskellCi.CI.Type

in  { dhallInstall = dhallInstall
    , dhallYamlInstall = dhallYamlInstall
    , dhallCi = dhallCi
    , checkDhall = checkDhall
    , CI = haskellCi.CI
    }
