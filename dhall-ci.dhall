let haskellCi =
      ./haskell-ci.dhall sha256:992e2717c6ffae819f5c3165346e3530e2bd781c85562a9c539e2b1123749aa0

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
        { name = "Install dhall-to-yaml &c."
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

let checkDhallYaml =
        λ(dhalls : List Text)
      → haskellCi.BuildStep.Name
          { name = "Check Dhall can be converted to YAML"
          , run =
                  ''
                  export PATH=$HOME/.cabal/bin:$PATH
                  ''
              ++  concatMap
                    Text
                    (   λ(d : Text)
                      → ''
                        dhall-to-yaml --file ${d}
                        ''
                    )
                    dhalls
          }

let dhallSteps =
        λ(steps : List haskellCi.BuildStep)
      →     haskellCi.ciNoMatrix
              (   [ haskellCi.checkout
                  , haskellCi.haskellEnv haskellCi.defaultEnv
                  , dhallInstall
                  ]
                # steps
              )
          ⫽ { name = "Dhall CI" }
        : haskellCi.CI.Type

let dhallCi =
        λ(dhalls : List Text)
      → dhallSteps [ checkDhall dhalls ] : haskellCi.CI.Type

in  { dhallInstall = dhallInstall
    , dhallYamlInstall = dhallYamlInstall
    , dhallCi = dhallCi
    , checkDhall = checkDhall
    , checkDhallYaml = checkDhallYaml
    , dhallSteps = dhallSteps
    , printEvent = haskellCi.printEvent
    , CI = haskellCi.CI.Type
    , BuildStep = haskellCi.BuildStep
    , Event = haskellCi.Event
    }
