# github-actions-dhall

This is a demonstration using Dhall to generate YAML for
github actions.

github-actions-dhall is
[self-hosting](https://github.com/vmchale/github-actions-dhall/blob/master/self-ci.dhall).

## Example

### Haskell

Store the following in `example.dhall`:

```dhall
let haskellCi = https://raw.githubusercontent.com/vmchale/github-actions-dhall/master/haskell-ci.dhall

in    haskellCi.generalCi
        haskellCi.matrixSteps
        ( Some
            { ghc = [ haskellCi.GHC.GHC881, haskellCi.GHC.GHC865 ]
            , cabal = [ haskellCi.Cabal.Cabal30 ]
            }
        )
    : haskellCi.CI.Type
```

Then, generate YAML with `dhall-to-yaml --file example.dhall`

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: "actions/checkout@v1"
      - uses: "actions/setup-haskell@v1"
        with:
          cabal-version: "${{ matrix.cabal }}"
          ghc-version: "${{ matrix.ghc }}"
      - name: "Install dependencies"
        run: |
          cabal update
          cabal build --enable-tests --enable-benchmarks --only-dependencies
      - name: Build
        run: "cabal build --enable-tests --enable-benchmarks"
      - name: Tests
        run: "cabal test"
      - name: Documentation
        run: "cabal haddock"
    strategy:
      matrix:
        cabal:
          - "3.0"
        ghc:
          - "8.8.1"
          - "8.6.5"
name: "Haskell CI"
on:
  - push
```

Have a look at
[hlint-lib](https://github.com/vmchale/hlint-lib/blob/master/self-ci.dhall) for
a more "organic" example.
