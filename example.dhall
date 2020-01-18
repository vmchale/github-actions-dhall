let haskellCi =
      ./haskell-ci.dhall sha256:fb2c05c51cd989dc7414c97d5c27fe2bf22ccb57f65d6e83bff1b8274006935f

in    haskellCi.generalCi
        haskellCi.matrixSteps
        ( Some
            { ghc = [ haskellCi.GHC.GHC881, haskellCi.GHC.GHC865 ]
            , cabal = [ haskellCi.Cabal.Cabal30 ]
            }
        )
    : haskellCi.CI.Type
