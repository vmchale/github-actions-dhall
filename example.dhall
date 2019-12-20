let haskellCi =
      ./haskell-ci.dhall sha256:5690c3ba762328bbe4409015cc1ebf2706c0b2e367733740deb7bee9d4252eac

in    haskellCi.generalCi
        haskellCi.matrixSteps
        ( Some
            { ghc = [ haskellCi.GHC.GHC881, haskellCi.GHC.GHC865 ]
            , cabal = [ haskellCi.Cabal.Cabal30 ]
            }
        )
    : haskellCi.CI.Type
