# DAT Haskell Labs

Each lab now has its own minimal build config. Run build commands from the lab
directory instead of using a root project file.

## Lab 1

```sh
cd lab1
cabal build all
cabal run exe:mps1
cabal run exe:mps2
cabal run exe:mps3
cabal run exe:me
```

## Lab 2

```sh
cd lab2/dat-prj
stack build
stack run life
```

## Lab 3

```sh
cd lab3
stack build
stack run holamon
stack run acumulador0
stack run acumulador
stack run hello-1
stack run hello-2
```

## Lab 4

```sh
cd lab4
cabal build all
cabal run exe:forums-app -- 4050
```

## Submission Archives

`lab2.zip` is generated from `lab2/dat-prj` and excludes build output such as
`.stack-work`, `dist-newstyle`, `stack.yaml.lock`, and editor metadata.
