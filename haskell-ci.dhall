let VersionInfo = { ghc-version : Text, cabal-version : Text }

let BuildStep =
      < Uses : { uses : Text, with : Optional VersionInfo }
      | Name : { name : Text, run : Text }
      >

let checkout =
      BuildStep.Uses { uses = "actions/checkout@v1", with = None VersionInfo }

let haskellEnv =
        λ(v : VersionInfo)
      → BuildStep.Uses { uses = "actions/setup-haskell@v1", with = Some v }

let defaultEnv = { ghc-version = "8.6.5", cabal-version = "3.0" }

let latestEnv = { ghc-version = "8.8.1", cabal-version = "3.0" }

let cabalDeps =
      BuildStep.Name
        { name = "Install dependencies"
        , run =
            ''
            cabal update
            cabal build --enable-tests --enable-benchmarks --only-dependencies
            ''
        }

let cabalBuild =
      BuildStep.Name
        { name = "Build"
        , run = "cabal build --enable-tests --enable-benchmarks"
        }

let cabalTest = BuildStep.Name { name = "Tests", run = "cabal test" }

let cabalDoc = BuildStep.Name { name = "Documentation", run = "cabal haddock" }


let CI =
      { name : Text
      , on : List Text
      , jobs : { build : { runs-on : Text, steps : List BuildStep } }
      }

let defaultCi =
        { name = "Haskell CI"
        , on = [ "push" ]
        , jobs =
            { build =
                { runs-on = "ubuntu-latest"
                , steps =
                    [ checkout
                    , haskellEnv defaultEnv
                    , cabalDeps
                    , cabalBuild
                    , cabalTest
                    , cabalDoc
                    ]
                }
            }
        }
      : CI

let defaultWithSteps =
        λ(sts : List BuildStep)
      →   defaultCi
        ⫽ { jobs =
              { build = { runs-on = defaultCi.jobs.build.runs-on, steps = sts }
              }
          }

in  { VersionInfo = VersionInfo
    , BuildStep = BuildStep
    , cabalDoc = cabalDoc
    , cabalTest = cabalTest
    , cabalDeps = cabalDeps
    , cabalBuild = cabalBuild
    , checkout = checkout
    , haskellEnv = haskellEnv
    , defaultEnv = defaultEnv
    , latestEnv = latestEnv
    , defaultCi = defaultCi
    , defaultWithSteps = defaultWithSteps
    , CI = CI
    }
