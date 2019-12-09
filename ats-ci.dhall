let haskellCi =
      ./haskell-ci.dhall sha256:ff0522efb1b85daaf578203a42e1caad156d6d461b318c1e7b83c3fcf5d144ba

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

let atsBuild =
        λ(pkgArgs : Optional Text)
      → haskellCi.BuildStep.Name
          { name = "Build ATS"
          , run =
              ''
              export PATH=$HOME/.local/bin:$PATH
              atspkg -V
              atspkg build -vv${mkPkgArgs pkgArgs}
              ''
          }

let atsTest =
        λ(pkgArgs : Optional Text)
      → haskellCi.BuildStep.Name
          { name = "Test ATS"
          , run =
              ''
              export PATH=$HOME/.local/bin:$PATH
              atspkg test -vv${mkPkgArgs pkgArgs}
              ''
          }

let atsSteps =
        λ(steps : List haskellCi.BuildStep)
      →   haskellCi.generalCi steps (None haskellCi.DhallMatrix)
        : haskellCi.CI.Type

let atsCi =
        atsSteps [ haskellCi.checkout, atspkgInstall, atsBuild (None Text) ]
      : haskellCi.CI.Type

in  { atspkgInstall = atspkgInstall
    , atsBuild = atsBuild
    , atsTest = atsTest
    , atsCi = atsCi
    , atsSteps = atsSteps
    , checkout = haskellCi.checkout
    , CI = haskellCi.CI
    }
