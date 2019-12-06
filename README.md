# github-actions-dhall

This library providers Dhall helper functions to generate YAML for
github actions.

## Example

Store the following in `example.dhall`:

```dhall
let haskellCi = https://raw.githubusercontent.com/vmchale/github-actions-dhall/master/haskell-ci.dhall
in

haskellCi.defaultCi
```

Then, generate YAML with

```
$ dhall-to-yaml --file example.yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: "actions/checkout@v1"
      - uses: "actions/setup-haskell@v1"
        with:
          cabal-version: "3.0"
          ghc-version: "8.6.5"
      - name: "Install dependencies"
        run: |
          cabal update
          cabal build --enable-tests --enable-benchmarks --only-dependencies
…
```
