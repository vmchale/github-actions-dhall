let haskellCi =
      ./haskell-ci.dhall sha256:992e2717c6ffae819f5c3165346e3530e2bd781c85562a9c539e2b1123749aa0

in    haskellCi.generalCi
        haskellCi.matrixSteps
        ( Some
            { ghc = [ haskellCi.GHC.GHC881, haskellCi.GHC.GHC865 ]
            , cabal = [ haskellCi.Cabal.Cabal30 ]
            }
        )
    : haskellCi.CI.Type
