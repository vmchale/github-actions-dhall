let haskellCi =
      ./haskell-ci.dhall sha256:053b3f92d301dab85217e1fd5c0478bc69841c3309604168a5a8121b4226ae54

let concatSep =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/9f259cd68870b912fbf2f2a08cd63dc3ccba9dc3/Prelude/Text/concatSep sha256:e4401d69918c61b92a4c0288f7d60a6560ca99726138ed8ebc58dca2cd205e58

let checkToml =
        λ(tomlFiles : List Text)
      → let bashDirs = concatSep " " tomlFiles

        in  haskellCi.BuildStep.Name
              { name = "Check TOML"
              , run =
                  "curl -sL https://raw.githubusercontent.com/vmchale/tomlcheck/master/sh/check | sh -s ${bashDirs}"
              }

let tomlCi =
        λ(tomlFiles : List Text)
      →     haskellCi.generalCi
              [ haskellCi.checkout, checkToml tomlFiles ]
              (None haskellCi.DhallMatrix.Type)
          ⫽ { name = "Toml check" }
        : haskellCi.CI.Type

in  { checkToml = checkToml, tomlCi = tomlCi, CI = haskellCi.CI.Type }
