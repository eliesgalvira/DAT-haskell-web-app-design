# DAT Labs

## Lab 2

These instructions start from the submitted archive `lab2.zip`.

### Requirements

You need `stack` installed.

The first build may download GHC and the project dependencies. This can take a
few minutes.

### Extract

Extract the archive:

```sh
unzip lab2.zip
```

It creates this directory:

```text
dat-prj/
```

Enter the extracted project:

```sh
cd dat-prj
```

If `dat-prj/` already exists from a previous extraction, remove it first:

```sh
rm -rf dat-prj
unzip lab2.zip
cd dat-prj
```

### Build

Build the `life` executable:

```sh
stack build life
```

### Run

Run the application:

```sh
stack run life
```

Open the URL printed by the program, usually:

```text
http://localhost:3708/
```

Stop the server with `Ctrl+C` in the terminal running `stack run life`.

### Controls

- `Click`: toggle a cell.
- `N`: advance one generation.
- `G`: change grid mode.
- `I`: zoom in.
- `O`: zoom out.
- Arrow keys: move the view.
- `H`: show or hide help.
- `S`: save the board to `board.json`.
- `L`: load the board from `board.json`.

`board.json` is created inside `dat-prj/` when you press `S`.

### Notes

This lab is prepared to run with Stack:

```sh
stack build life
stack run life
```

You do not need Cabal to complete Lab 2.

If an editor reports that `Data.ByteString.Lazy` belongs to a hidden package,
open the extracted `dat-prj/` folder as the project root and check that
`stack build life` works from that same folder.

Browser requests such as `favicon.ico` or `.well-known/...` may appear in the
terminal. They can be ignored if the application works in the browser.

## Lab 5

These instructions start from the submitted archive `lab5.zip`.

### Environment

Use the DAT course VM for the full build and browser test.

The frontend JavaScript build requires the GHC JavaScript backend tools used by
the course setup:

```sh
javascript-unknown-ghcjs-ghc
javascript-unknown-ghcjs-ghc-pkg
```

The `forums-frontend/Makefile` calls `../js-cabal`, and `js-cabal` is configured
to use those tools. A normal Linux/macOS/Windows system with only regular GHC can
build native Haskell targets with `cabal build all`, but it will not complete
`make build` for the browser frontend unless these JavaScript compiler tools are
installed and available on `PATH`.

You can check the VM setup with:

```sh
command -v javascript-unknown-ghcjs-ghc
command -v javascript-unknown-ghcjs-ghc-pkg
```

### Extract

Extract the archive. It creates this directory:

```text
dat-prj-5/
```

Enter the extracted project:

```sh
cd dat-prj-5
```

### Build

Build all Haskell targets:

```sh
cabal build all
```

Build the JavaScript frontend:

```sh
cd forums-frontend
make clean
make build
```

The frontend build creates the generated `public/` directory.

### Run

In each terminal, first enter the extracted project:

```sh
cd dat-prj-5
```

Run the backend in one terminal:

```sh
cd forums-backend
cabal run forums-backend -- 5001
```

Run the frontend static server in a second terminal:

```sh
cd forums-frontend
make serve
```

Open the browser in a third terminal:

```sh
cd forums-frontend
make browse
```

If the default browser command is not available, use Chromium:

```sh
make browse browser=chromium
```

### Stop Servers

Stop `make serve` or the backend with `Ctrl+C` in the terminal where it is running.

Closing the browser does not stop `make serve`.

If port `8008` is busy, find and stop the old frontend server:

```sh
lsof -i :8008
kill PID
```

### Notes

The archive intentionally excludes generated build output such as:

- `dist-newstyle/`
- `forums-frontend/public/`
- `forums-frontend/browse-user-data/`

These directories are recreated by the build and run commands above.
