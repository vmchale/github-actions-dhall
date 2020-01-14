let pyCi =
      ./python-ci.dhall sha256:cad811de5c4ac3a5c073f5ad692d255a3547b517fdb97759d1f96324f80576a1

let concatSep =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatSep sha256:e4401d69918c61b92a4c0288f7d60a6560ca99726138ed8ebc58dca2cd205e58

let installVint =
      pyCi.BuildStep.Name
        { name = "Install vim-vint"
        , run =
            ''
            pip install vim-vint --upgrade
            ''
        }

let checkVim =
        λ(vimscript : List Text)
      → let vimArgs = concatSep " " vimscript

        in  pyCi.BuildStep.Name
              { name = "Check Vimscript"
              , run =
                  ''
                  export PATH=$HOME/.local/bin:$PATH
                  vint ${vimArgs}
                  ''
              }

let vimCi =
        λ(vimscript : List Text)
      →     pyCi.ciNoMatrix [ pyCi.checkout, installVint, checkVim vimscript ]
          ⫽ { name = "Vimscript check" }
        : pyCi.CI.Type

in  { checkVim = checkVim, vimCi = vimCi, CI = pyCi.CI.Type }
