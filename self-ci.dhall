let haskellCi = ./haskell-ci.dhall

in    haskellCi.generalCi
        [ haskellCi.checkout
        , haskellCi.haskellEnv haskellCi.defaultEnv
        , haskellCi.BuildStep.Name
            { name = "Install dhall"
            , run =
                ''
                cabal install dhall
                export PATH=$HOME/.cabal/bin:$PATH
                ''
            }
        , haskellCi.BuildStep.Name
            { name = "Check dhall"
            , run =
                ''
                dhall --file haskell-ci.dhall
                dhall --file example.dhall
                dhall --file self-ci.dhall
                ''
            }
        ]
        (None haskellCi.DhallMatrix)
    : haskellCi.CI.Type
