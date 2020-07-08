let haskellCi = ./haskell-ci.dhall

let concatSep =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatSep sha256:e4401d69918c61b92a4c0288f7d60a6560ca99726138ed8ebc58dca2cd205e58

let optionalFold =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/87993319329f3c00920d6e882365276925a4aa6a/Prelude/Optional/fold.dhall sha256:c5b9d72f6f62bdaa0e196ac1c742cc175cd67a717b880fb8aec1333a5a4132cf

let atspkgInstall =
      haskellCi.BuildStep.Name
        { name = "Install atspkg"
        , run =
            ''
            curl -sSl https://raw.githubusercontent.com/vmchale/atspkg/master/bash/install.sh | sh -s
            ''
        }

let mkPkgArgs =
      λ(pkgArgs : Optional Text) →
        optionalFold Text pkgArgs Text (λ(x : Text) → " --pkg-args ${x}") ""

let mkTgts = concatSep " "

let atsBuildTargets =
      λ(targets : List Text) →
      λ(pkgArgs : Optional Text) →
        haskellCi.BuildStep.Name
          { name = "Build ATS"
          , run =
              ''
              export PATH=$HOME/.local/bin:$PATH
              atspkg -V
              atspkg build -vv${mkPkgArgs pkgArgs} ${mkTgts targets}
              ''
          }

let atsCheckPkg =
      haskellCi.BuildStep.Name
        { name = "Check pkg.dhall"
        , run =
            ''
            export PATH=$HOME/.local/bin:$PATH
            atspkg check pkg.dhall
            ''
        }

let atsBuild = atsBuildTargets ([] : List Text)

let atsTestTargets =
      λ(targets : List Text) →
      λ(pkgArgs : Optional Text) →
        haskellCi.BuildStep.Name
          { name = "Test ATS"
          , run =
              ''
              export PATH=$HOME/.local/bin:$PATH
              atspkg test -vv${mkPkgArgs pkgArgs} ${mkTgts targets}
              ''
          }

let atsTest = atsTestTargets ([] : List Text)

let atsSteps =
      λ(steps : List haskellCi.BuildStep) →
        haskellCi.ciNoMatrix steps ⫽ { name = "ATS CI" }

let atsCi =
        atsSteps [ haskellCi.checkout, atspkgInstall, atsBuild (None Text) ]
      : haskellCi.CI.Type

in  { atspkgInstall
    , atsBuild
    , atsBuildTargets
    , atsTest
    , atsCi
    , atsSteps
    , atsCheckPkg
    , checkout = haskellCi.checkout
    , CI = haskellCi.CI
    , BuildStep = haskellCi.BuildStep
    , Event = haskellCi.Event
    }
