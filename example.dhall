let haskellCi =
      ./haskell-ci.dhall sha256:ef332e5a6a293a84ebc6b52fe5889f7000b4621378970dc304671125d4a5259c

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
