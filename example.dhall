let haskellCi = ./haskell-ci.dhall

in    haskellCi.generalCi
        haskellCi.matrixSteps
        ( Some
            { ghc = [ haskellCi.GHC.GHC881, haskellCi.GHC.GHC865 ]
            , cabal = [ haskellCi.Cabal.Cabal30 ]
            , operating-system = [ haskellCi.OS.Ubuntu1804, haskellCi.OS.MacOS ]
            }
        )
    : haskellCi.CI.Type
