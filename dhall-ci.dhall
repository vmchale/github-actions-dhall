let haskellCi =
      ./haskell-ci.dhall sha256:bb6b0eee75d9f5d9e62b7a0386efef5c1d0d6fb1415eab5a33500976cc70c886

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
