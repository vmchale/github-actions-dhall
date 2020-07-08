let haskellCi = ./haskell-ci.dhall

let mapOptional =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/87993319329f3c00920d6e882365276925a4aa6a/Prelude/Optional/map sha256:501534192d988218d43261c299cc1d1e0b13d25df388937add784778ab0054fa

let PyArch = < X86 | X64 >

let PyVer = < Py3 | Py2 | PyPy2 | PyPy3 >

let PyInfoDhall =
      { Type = { python-version : PyVer, architecture : Optional PyArch }
      , default = { python-version = PyVer.Py3, architecture = None PyArch }
      }

let printPyVer =
      λ(pyVer : PyVer) →
        merge
          { Py2 = "2.x", Py3 = "3.x", PyPy2 = "pypy2", PyPy3 = "pypy3" }
          pyVer

let printPyArch = λ(pyArch : PyArch) → merge { X86 = "x86", X64 = "x64" } pyArch

let printPyInfoDhall =
      λ(pyInfo : PyInfoDhall.Type) →
        { python-version = printPyVer pyInfo.python-version
        , architecture = mapOptional PyArch Text printPyArch pyInfo.architecture
        }

let wheelInstall =
      haskellCi.BuildStep.Name
        { name = "Install wheel"
        , run =
            ''
            pip install wheel --upgrade
            ''
        }

in  { PyInfo = haskellCi.PyInfo
    , PyInfoDhall
    , PyArch
    , PyVer
    , BuildStep = haskellCi.BuildStep
    , CI = haskellCi.CI
    , Event = haskellCi.Event
    , printPyInfoDhall
    , printPyArch
    , printPyVer
    , ciNoMatrix = haskellCi.ciNoMatrix
    , checkout = haskellCi.checkout
    , wheelInstall
    }
