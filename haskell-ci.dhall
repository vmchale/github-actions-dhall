let map =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/List/map sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680

let mapOptional =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/87993319329f3c00920d6e882365276925a4aa6a/Prelude/Optional/map sha256:501534192d988218d43261c299cc1d1e0b13d25df388937add784778ab0054fa

let concatSep =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatSep sha256:e4401d69918c61b92a4c0288f7d60a6560ca99726138ed8ebc58dca2cd205e58

let GHC = < GHC7103 | GHC802 | GHC822 | GHC844 | GHC865 | GHC883 | GHC8101 >

let Cabal = < Cabal32 | Cabal30 | Cabal24 | Cabal22 | Cabal20 >

let OS = < Ubuntu1804 | Ubuntu1604 | MacOS | Windows >

let VersionInfo =
      { Type =
          { ghc-version : Optional Text
          , cabal-version : Optional Text
          , stack-version : Optional Text
          , enable-stack : Optional Bool
          , stack-no-global : Optional Bool
          , stack-setup-ghc : Optional Bool
          }
      , default =
        { ghc-version = Some "8.10.1"
        , cabal-version = Some "3.2"
        , stack-version = None Text
        , enable-stack = Some False
        , stack-no-global = None Bool
        , stack-setup-ghc = None Bool
        }
      }

let PyInfo = { python-version : Text, architecture : Optional Text }

let CacheCfg =
      { Type = { path : Text, key : Text, restoreKeys : Optional Text }
      , default.restoreKeys = None Text
      }

let BuildStep =
      < Uses :
          { uses : Text
          , id : Optional Text
          , `with` : Optional VersionInfo.Type
          }
      | Name : { name : Text, run : Text }
      | UseCache : { uses : Text, `with` : CacheCfg.Type }
      | UsePy : { uses : Text, `with` : PyInfo }
      | AwsEnv :
          { name : Text
          , run : Text
          , env : { AWS_ACCESS_KEY_ID : Text, AWS_SECRET_ACCESS_KEY : Text }
          }
      >

let DhallVersion = { ghc-version : GHC, cabal-version : Cabal }

let Matrix = { matrix : { ghc : List Text, cabal : List Text } }

let DhallMatrix =
      { Type = { ghc : List GHC, cabal : List Cabal }
      , default = { ghc = [ GHC.GHC865 ], cabal = [ Cabal.Cabal32 ] }
      }

let Event = < push | release | pull_request >

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
      , default =
        { name = "Haskell CI", on = [ Event.push, Event.pull_request ] }
      }

let printGhc =
      λ(ghc : GHC) →
        merge
          { GHC7103 = "7.10.3"
          , GHC802 = "8.0.2"
          , GHC822 = "8.2.2"
          , GHC844 = "8.4.4"
          , GHC865 = "8.6.5"
          , GHC883 = "8.8.3"
          , GHC8101 = "8.10.1"
          }
          ghc

let printOS =
      λ(os : OS) →
        merge
          { Windows = "windows-latest"
          , Ubuntu1804 = "ubuntu-18.04"
          , Ubuntu1604 = "ubuntu-16.04"
          , MacOS = "macos-latest"
          }
          os

let printCabal =
      λ(cabal : Cabal) →
        merge
          { Cabal32 = "3.2"
          , Cabal30 = "3.0"
          , Cabal24 = "2.4"
          , Cabal22 = "2.2"
          , Cabal20 = "2.0"
          }
          cabal

let printEnv =
      λ(v : DhallVersion) →
        VersionInfo::{
        , ghc-version = Some (printGhc v.ghc-version)
        , cabal-version = Some (printCabal v.cabal-version)
        }

let printMatrix =
      λ(v : DhallMatrix.Type) →
        { ghc = map GHC Text printGhc v.ghc
        , cabal = map Cabal Text printCabal v.cabal
        }

let cache =
      BuildStep.UseCache
        { uses = "actions/cache@v1"
        , `with` =
          { path = "\${{ steps.setup-haskell-cabal.outputs.cabal-store }}"
          , key = "\${{ runner.os }}-\${{ matrix.ghc }}-cabal"
          , restoreKeys = None Text
          }
        }

let stackCache =
      BuildStep.UseCache
        { uses = "actions/cache@v1"
        , `with` =
          { path = "~/.stack"
          , key = "\${{ runner.os }}-\${{ matrix.ghc }}-stack"
          , restoreKeys = None Text
          }
        }

let checkout =
      BuildStep.Uses
        { uses = "actions/checkout@v1"
        , id = None Text
        , `with` = None VersionInfo.Type
        }

let haskellEnv =
      λ(v : VersionInfo.Type) →
        BuildStep.Uses
          { uses = "actions/setup-haskell@v1.1"
          , id = Some "setup-haskell-cabal"
          , `with` = Some v
          }

let defaultEnv =
      printEnv { ghc-version = GHC.GHC883, cabal-version = Cabal.Cabal32 }

let latestEnv =
      printEnv { ghc-version = GHC.GHC883, cabal-version = Cabal.Cabal32 }

let matrixOS = "\${{ matrix.operating-system }}"

let matrixEnv =
      VersionInfo::{
      , ghc-version = Some "\${{ matrix.ghc }}"
      , cabal-version = Some "\${{ matrix.cabal }}"
      }

let stackEnv =
        { ghc-version = Some "8.6.5"
        , cabal-version = None Text
        , stack-version = Some "latest"
        , enable-stack = Some True
        , stack-no-global = Some True
        , stack-setup-ghc = None Bool
        }
      : VersionInfo.Type

let mkMatrix = λ(st : DhallMatrix.Type) → { matrix = printMatrix st } : Matrix

let hlintDirs =
      λ(dirs : List Text) →
        let bashDirs = concatSep " " dirs

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

let cmdWithFlags =
      λ(cmd : Text) →
      λ(subcommand : Text) →
      λ(flags : List Text) →
        let flagStr = concatSep " " flags

        in  BuildStep.Name
              { name = subcommand, run = "${cmd} ${subcommand} ${flagStr}" }

let cabalWithFlags = cmdWithFlags "cabal"

let cabalBuildWithFlags = cabalWithFlags "build"

let cabalBuild = cabalBuildWithFlags [ "--enable-tests", "--enable-benchmarks" ]

let stackWithFlags = cmdWithFlags "stack"

let stackBuildWithFlags = stackWithFlags "build"

let stackBuild =
      stackBuildWithFlags
        [ "--bench", "--test", "--no-run-tests", "--no-run-benchmarks" ]

let cabalTest = cabalWithFlags "test" ([] : List Text)

let stackTest = stackWithFlags "test" ([] : List Text)

let cabalTestProfiling = cabalWithFlags "test" [ "--enable-profiling" ]

let cabalTestCoverage = cabalWithFlags "test" [ "--enable-coverage" ]

let cabalDoc = cabalWithFlags "haddock" ([] : List Text)

let generalCi =
      λ(sts : List BuildStep) →
      λ(mat : Optional DhallMatrix.Type) →
          CI::{
          , jobs.build =
            { runs-on = printOS OS.Ubuntu1804
            , steps = sts
            , strategy = mapOptional DhallMatrix.Type Matrix mkMatrix mat
            }
          }
        : CI.Type

let ciNoMatrix = λ(sts : List BuildStep) → generalCi sts (None DhallMatrix.Type)

let stepsEnv =
      λ(v : VersionInfo.Type) →
          [ checkout
          , haskellEnv v
          , cache
          , cabalDeps
          , cabalBuild
          , cabalTest
          , cabalDoc
          ]
        : List BuildStep

let stackSteps =
        [ checkout, haskellEnv stackEnv, stackCache, stackBuild, stackTest ]
      : List BuildStep

let matrixSteps = stepsEnv matrixEnv : List BuildStep

let defaultSteps = stepsEnv defaultEnv : List BuildStep

let hlintAction =
      λ(dirs : List Text) →
            generalCi [ checkout, hlintDirs dirs ] (None DhallMatrix.Type)
          ⫽ { name = "HLint checks" }
        : CI.Type

let defaultCi = generalCi defaultSteps (None DhallMatrix.Type) : CI.Type

in  { VersionInfo
    , BuildStep
    , Matrix
    , CI
    , GHC
    , Cabal
    , DhallVersion
    , DhallMatrix
    , CacheCfg
    , OS
    , PyInfo
    , Event
    , cabalDoc
    , cabalTest
    , cabalDeps
    , cabalBuild
    , cabalWithFlags
    , cabalBuildWithFlags
    , cabalTestProfiling
    , cabalTestCoverage
    , checkout
    , haskellEnv
    , defaultEnv
    , latestEnv
    , matrixEnv
    , defaultCi
    , generalCi
    , mkMatrix
    , printMatrix
    , printEnv
    , printGhc
    , printCabal
    , printOS
    , stepsEnv
    , matrixOS
    , matrixSteps
    , defaultSteps
    , hlintDirs
    , hlintAction
    , ciNoMatrix
    , cache
    , stackEnv
    , stackWithFlags
    , stackSteps
    , stackBuild
    , stackTest
    , stackCache
    }
