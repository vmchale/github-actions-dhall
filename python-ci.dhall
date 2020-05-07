let haskellCi =
      ./haskell-ci.dhall sha256:2de95c8bd086c21660c2849dfe2d9af72e675bed44396159d647292d329a20e4

let mapOptional =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Optional/map sha256:e7f44219250b89b094fbf9996e04b5daafc0902d864113420072ae60706ac73d

let PyArch = < X86 | X64 >

let PyVer = < Py3 | Py2 | PyPy2 | PyPy3 >

let PyInfoDhall =
      { Type = { python-version : PyVer, architecture : Optional PyArch }
      , default = { python-version = PyVer.Py3, architecture = None PyArch }
      }

let printPyVer =
        λ(pyVer : PyVer)
      → merge
          { Py2 = "2.x", Py3 = "3.x", PyPy2 = "pypy2", PyPy3 = "pypy3" }
          pyVer

let printPyArch = λ(pyArch : PyArch) → merge { X86 = "x86", X64 = "x64" } pyArch

let printPyInfoDhall =
        λ(pyInfo : PyInfoDhall.Type)
      → { python-version = printPyVer pyInfo.python-version
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
