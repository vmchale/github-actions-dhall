let map =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/List/map sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680

let mapOptional =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Optional/map sha256:e7f44219250b89b094fbf9996e04b5daafc0902d864113420072ae60706ac73d

let concatSep =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatSep sha256:e4401d69918c61b92a4c0288f7d60a6560ca99726138ed8ebc58dca2cd205e58

let GHC = < GHC802 | GHC822 | GHC844 | GHC865 | GHC881 >

let Cabal = < Cabal30 | Cabal24 | Cabal22 | Cabal20 >

let OS = < Ubuntu1804 | Ubuntu1604 | MacOS | Windows >

let VersionInfo = { ghc-version : Text, cabal-version : Text }

let PyInfo = { python-version : Text, architecture : Optional Text }

let CacheCfg =
      { Type = { path : Text, key : Text, restoreKeys : Optional Text }
      , default = { restoreKeys = None Text }
      }

let BuildStep =
      < Uses : { uses : Text, with : Optional VersionInfo }
      | Name : { name : Text, run : Text }
      | UseCache : { uses : Text, with : CacheCfg.Type }
      | UsePy : { uses : Text, with : PyInfo }
      >

let DhallVersion = { ghc-version : GHC, cabal-version : Cabal }

let Matrix = { matrix : { ghc : List Text, cabal : List Text } }

let DhallMatrix =
      { Type = { ghc : List GHC, cabal : List Cabal }
      , default = { ghc = [ GHC.GHC865 ], cabal = [ Cabal.Cabal30 ] }
      }

let Event =
      < push
      | release
      | pull_request
      | Schedule : { schedule : { cron : Text } }
      >

let CI =
      { Type =
          { name : Text
          , on : List Event
          , jobs :
              { build :
                  { runs-on : Text
                  , steps : List BuildStep
                  , strategy : Optional Matrix
                  }
              }
          }
      , default = { name = "Haskell CI", on = [ Event.push ] }
      }

let printGhc =
        λ(ghc : GHC)
      → merge
          { GHC802 = "8.0.2"
          , GHC822 = "8.2.2"
          , GHC844 = "8.4.4"
          , GHC865 = "8.6.5"
          , GHC881 = "8.8.1"
          }
          ghc

let printOS =
        λ(os : OS)
      → merge
          { Windows = "windows-latest"
          , Ubuntu1804 = "ubuntu-18.04"
          , Ubuntu1604 = "ubuntu-16.04"
          , MacOS = "macos-latest"
          }
          os

let printCabal =
        λ(cabal : Cabal)
      → merge
          { Cabal30 = "3.0", Cabal24 = "2.4", Cabal22 = "2.2", Cabal20 = "2.0" }
          cabal

let printEnv =
        λ(v : DhallVersion)
      → { ghc-version = printGhc v.ghc-version
        , cabal-version = printCabal v.cabal-version
        }

let printMatrix =
        λ(v : DhallMatrix.Type)
      → { ghc = map GHC Text printGhc v.ghc
        , cabal = map Cabal Text printCabal v.cabal
        }

let checkout =
      BuildStep.Uses { uses = "actions/checkout@v1", with = None VersionInfo }

let haskellEnv =
        λ(v : VersionInfo)
      → BuildStep.Uses { uses = "actions/setup-haskell@v1", with = Some v }

let defaultEnv =
      printEnv { ghc-version = GHC.GHC865, cabal-version = Cabal.Cabal30 }

let latestEnv =
      printEnv { ghc-version = GHC.GHC881, cabal-version = Cabal.Cabal30 }

let matrixOS = "\${{ matrix.operating-system }}"

let matrixEnv =
      { ghc-version = "\${{ matrix.ghc }}"
      , cabal-version = "\${{ matrix.cabal }}"
      }

let mkMatrix = λ(st : DhallMatrix.Type) → { matrix = printMatrix st } : Matrix

let hlintDirs =
        λ(dirs : List Text)
      → let bashDirs = concatSep " " dirs

        in  BuildStep.Name
              { name = "Run hlint"
              , run =
                  "curl -sSL https://raw.github.com/ndmitchell/hlint/master/misc/run.sh | sh -s ${bashDirs}"
              }

let cabalDeps =
      BuildStep.Name
        { name = "Install dependencies"
        , run =
            ''
            cabal update
            cabal build --enable-tests --enable-benchmarks --only-dependencies
            ''
        }

let cabalWithFlags =
        λ(subcommand : Text)
      → λ(flags : List Text)
      → let flagStr = concatSep " " flags

        in  BuildStep.Name
              { name = subcommand, run = "cabal ${subcommand} ${flagStr}" }

let cabalBuildWithFlags = cabalWithFlags "build"

let cabalBuild = cabalBuildWithFlags [ "--enable-tests", "--enable-benchmarks" ]

let cabalTest = cabalWithFlags "test" ([] : List Text)

let cabalTestProfiling = cabalWithFlags "test" [ "--enable-profiling" ]

let cabalTestCoverage = cabalWithFlags "test" [ "--enable-coverage" ]

let cabalDoc = cabalWithFlags "haddock" ([] : List Text)

let generalCi =
        λ(sts : List BuildStep)
      → λ(mat : Optional DhallMatrix.Type)
      →   CI::{
          , jobs =
              { build =
                  { runs-on = printOS OS.Ubuntu1804
                  , steps = sts
                  , strategy = mapOptional DhallMatrix.Type Matrix mkMatrix mat
                  }
              }
          }
        : CI.Type

let ciNoMatrix = λ(sts : List BuildStep) → generalCi sts (None DhallMatrix.Type)

let stepsEnv =
        λ(v : VersionInfo)
      →   [ checkout, haskellEnv v, cabalDeps, cabalBuild, cabalTest, cabalDoc ]
        : List BuildStep

let matrixSteps = stepsEnv matrixEnv : List BuildStep

let defaultSteps = stepsEnv defaultEnv : List BuildStep

let hlintAction =
        λ(dirs : List Text)
      →     generalCi [ checkout, hlintDirs dirs ] (None DhallMatrix.Type)
          ⫽ { name = "HLint checks" }
        : CI.Type

let defaultCi = generalCi defaultSteps (None DhallMatrix.Type) : CI.Type

in  { VersionInfo = VersionInfo
    , BuildStep = BuildStep
    , Matrix = Matrix
    , CI = CI
    , GHC = GHC
    , Cabal = Cabal
    , DhallVersion = DhallVersion
    , DhallMatrix = DhallMatrix
    , CacheCfg = CacheCfg
    , OS = OS
    , PyInfo = PyInfo
    , Event = Event
    , cabalDoc = cabalDoc
    , cabalTest = cabalTest
    , cabalDeps = cabalDeps
    , cabalBuild = cabalBuild
    , cabalWithFlags = cabalWithFlags
    , cabalBuildWithFlags = cabalBuildWithFlags
    , cabalTestProfiling = cabalTestProfiling
    , cabalTestCoverage = cabalTestCoverage
    , checkout = checkout
    , haskellEnv = haskellEnv
    , defaultEnv = defaultEnv
    , latestEnv = latestEnv
    , matrixEnv = matrixEnv
    , defaultCi = defaultCi
    , generalCi = generalCi
    , mkMatrix = mkMatrix
    , printMatrix = printMatrix
    , printEnv = printEnv
    , printGhc = printGhc
    , printCabal = printCabal
    , printOS = printOS
    , stepsEnv = stepsEnv
    , matrixOS = matrixOS
    , matrixSteps = matrixSteps
    , defaultSteps = defaultSteps
    , hlintDirs = hlintDirs
    , hlintAction = hlintAction
    , ciNoMatrix = ciNoMatrix
    }
