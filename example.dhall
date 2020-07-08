let haskellCi =
      ./haskell-ci.dhall sha256:48c4cdf0faac0d1fd40884ff938abb3f1e8049e09a032fbec24e8ca337ce6ff9

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
