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

let atsBuild =
        λ(dhalls : List Text)
      → haskellCi.BuildStep.Name
          { name = "Build ATS"
          , run =
              ''
              export PATH=$HOME/.local/bin:$PATH
              atspkg -V
              atspkg build -vv
              ''
          }

let atsCi =
        haskellCi.generalCi
          [ haskellCi.checkout, atspkgInstall ]
          (None haskellCi.DhallMatrix)
      : haskellCi.CI.Type

in  { atspkgInstall = atspkgInstall
    , atsBuild = atsBuild
    , atsCi = atsCi
    , CI = haskellCi.CI
    }
