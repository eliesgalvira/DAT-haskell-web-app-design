# DAT Haskell Labs

## Build

```sh
cabal build all            # Build everything
cabal build lib:lab1-internals  # Build only the lab1 library
cabal build exe:mps1       # Build a single executable (mps1, mps2, mps3, me)
```

## Run

```sh
cabal run mps1 -- <args>   # Run an executable with arguments
cabal run me -- <args>
```

## Clean

```sh
cabal clean                # Remove all build artifacts
```

## REPL

```sh
cabal repl lab1-internals  # Load lab1 library modules in GHCi
cabal repl exe:mps1        # Load an executable in GHCi
```
