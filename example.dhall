let haskellCi =
      ./haskell-ci.dhall sha256:2f7f742e67407a569b4b4749692d29d520131fb146a6e096012ff31c5f43bb03

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
