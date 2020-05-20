let haskellCi =
      ./haskell-ci.dhall sha256:1adcb8f5a1e09f8b22ac04f2437a490a7ae2a85b192d7ae8cc7b745698e41cf7

in    haskellCi.generalCi
        haskellCi.matrixSteps
        ( Some
            { ghc =
              [ haskellCi.GHC.GHC8101
              , haskellCi.GHC.GHC883
              , haskellCi.GHC.GHC865
              ]
            , cabal = [ haskellCi.Cabal.Cabal32 ]
            }
        )
    : haskellCi.CI.Type
