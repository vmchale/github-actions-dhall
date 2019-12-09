let haskellCi =
      ./haskell-ci.dhall sha256:decfd4579e49d96095b3dfaaf82e31db96028ae7656796480e4764f30d60d790

let concatSep =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatSep sha256:e4401d69918c61b92a4c0288f7d60a6560ca99726138ed8ebc58dca2cd205e58

let atspkgInstall =
      haskellCi.BuildStep.Name
        { name = "Install atspkg"
        , run =
            ''
            curl -sSl https://raw.githubusercontent.com/vmchale/atspkg/master/bash/install.sh | sh -s
            ''
        }

let mkPkgArgs =
        λ(pkgArgs : Optional Text)
      → Optional/fold Text pkgArgs Text (λ(x : Text) → " --pkg-args ${x}") ""

let mkTgts = concatSep " "

let atsBuildTargets =
        λ(targets : List Text)
      → λ(pkgArgs : Optional Text)
      → haskellCi.BuildStep.Name
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
        λ(targets : List Text)
      → λ(pkgArgs : Optional Text)
      → haskellCi.BuildStep.Name
          { name = "Test ATS"
          , run =
              ''
              export PATH=$HOME/.local/bin:$PATH
              atspkg test -vv${mkPkgArgs pkgArgs} ${mkTgts targets}
              ''
          }

let atsTest = atsTestTargets ([] : List Text)

let atsSteps =
        λ(steps : List haskellCi.BuildStep)
      →   haskellCi.generalCi steps (None haskellCi.DhallMatrix)
        : haskellCi.CI.Type

let atsCi =
        atsSteps [ haskellCi.checkout, atspkgInstall, atsBuild (None Text) ]
      : haskellCi.CI.Type

in  { atspkgInstall = atspkgInstall
    , atsBuild = atsBuild
    , atsBuildTargets = atsBuildTargets
    , atsTest = atsTest
    , atsCi = atsCi
    , atsSteps = atsSteps
    , atsCheckPkg = atsCheckPkg
    , checkout = haskellCi.checkout
    , CI = haskellCi.CI
    }
