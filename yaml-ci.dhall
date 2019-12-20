let pyCi =
      ./python-ci.dhall sha256:23a82a8b9862e36b5b660e6736645d201bf639a3a73e0337047121c5caa61bfa

let concatSep =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatSep sha256:e4401d69918c61b92a4c0288f7d60a6560ca99726138ed8ebc58dca2cd205e58

let installYamllint =
      pyCi.BuildStep.Name
        { name = "Install yamllint"
        , run =
            ''
            pip install yamllint --upgrade
            ''
        }

let checkYaml =
        λ(yamlFiles : List Text)
      → let yamlArgs = concatSep " " yamlFiles

        in  pyCi.BuildStep.Name
              { name = "Check YAML"
              , run =
                  ''
                  export PATH=$HOME/.local/bin:$PATH
                  yamllint ${yamlArgs}
                  ''
              }

let yamlCi =
        λ(yamlFiles : List Text)
      →     pyCi.ciNoMatrix
              [ pyCi.checkout
              , pyCi.wheelInstall
              , installYamllint
              , checkYaml yamlFiles
              ]
          ⫽ { name = "YAML check" }
        : pyCi.CI.Type

in  { checkYaml = checkYaml
    , yamlCi = yamlCi
    , CI = pyCi.CI.Type
    , Event = pyCi.Event
    }
