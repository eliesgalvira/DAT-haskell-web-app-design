# DAT Lab 5

These instructions start from the submitted archive `lab5.zip`.

## Environment

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

## Extract

Extract the archive. It creates this directory:

```text
dat-prj-5/
```

Enter the extracted project:

```sh
cd dat-prj-5
```

## Build

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

## Run

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

## Stop Servers

Stop `make serve` or the backend with `Ctrl+C` in the terminal where it is running.

Closing the browser does not stop `make serve`.

If port `8008` is busy, find and stop the old frontend server:

```sh
lsof -i :8008
kill PID
```

## Notes

The archive intentionally excludes generated build output such as:

- `dist-newstyle/`
- `forums-frontend/public/`
- `forums-frontend/browse-user-data/`

These directories are recreated by the build and run commands above.
