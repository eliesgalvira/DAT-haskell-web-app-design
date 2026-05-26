# DAT Haskell Labs

## Build

```sh
cabal build all            # Build everything
cabal build lib:lab1-internals  # Build only the lab1 library
cabal build exe:mps1       # Build a single executable
```

## Run

```sh
cabal run mps1 -- <args>   # Run an executable with arguments
cabal run me -- <args>
```

Runnable targets:

```sh
cabal run exe:mps1
cabal run exe:mps2
cabal run exe:mps3
cabal run exe:me
cabal run exe:exemple
cabal run exe:life
cabal run exe:holamon
cabal run exe:acumulador0
cabal run exe:acumulador
cabal run exe:hello-1
cabal run exe:hello-2
cabal run exe:forums-app -- 4050
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
