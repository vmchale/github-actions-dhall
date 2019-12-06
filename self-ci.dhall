let dhallCi = ./dhall-ci.dhall sha256:77be63c6bd5c9978b93e1eb64adca91e5481e7346c96f34a8b58b1992b368ffd

in    dhallCi.dhallCi [ "haskell-ci.dhall", "example.dhall", "self-ci.dhall" ]
    : dhallCi.CI.Type
