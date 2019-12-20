let haskellCi =
      ./haskell-ci.dhall sha256:0436a5c08f98e083bfb147330ff273f2b182a9e695e0e67441c0f22c3bf4dc4d

in    haskellCi.generalCi
        haskellCi.matrixSteps
        ( Some
            { ghc = [ haskellCi.GHC.GHC881, haskellCi.GHC.GHC865 ]
            , cabal = [ haskellCi.Cabal.Cabal30 ]
            }
        )
    : haskellCi.CI.Type
