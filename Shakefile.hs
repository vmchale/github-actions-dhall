#!/usr/bin/env cabal
{- cabal:
build-depends: base, shake-dhall, shake
default-language: Haskell2010
ghc-options: -Wall -threaded -rtsopts "-with-rtsopts=-I0 -qg -qb"
-}

import           Development.Shake
import           Development.Shake.Dhall

main :: IO ()
main = shakeArgs shakeOptions { shakeFiles = ".shake", shakeLint = Just LintBasic, shakeChange = ChangeModtimeAndDigestInput } $ do
    want [ ".github/workflows/dhall.yml" ]

    ".github/workflows/dhall.yml" %> \out -> do
        let inp = "self-ci.dhall"
        needDhall [inp]
        command [] "dhall-to-yaml-ng" ["--file", inp, "--output", out]
