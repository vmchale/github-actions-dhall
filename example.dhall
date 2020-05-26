let haskellCi =
      ./haskell-ci.dhall sha256:abbcf1ffd0630835e80fe7c953e6fd2cacc8f8a2f70a0250b7e8f5a68171b232

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
