let haskellCi =
      ./haskell-ci.dhall sha256:32bae084b52a84d8f5d52727b09717baf4b353a2cbf56c3c66d523ca905b237a

in    haskellCi.generalCi
        haskellCi.matrixSteps
        ( Some
            { ghc = [ haskellCi.GHC.GHC881, haskellCi.GHC.GHC865 ]
            , cabal = [ haskellCi.Cabal.Cabal30 ]
            }
        )
    : haskellCi.CI.Type
