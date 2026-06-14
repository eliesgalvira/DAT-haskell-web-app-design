# DAT Lab 5

These instructions start from the submitted archive `lab5.zip`.

## Environment

The course VM already includes the JavaScript compiler tools needed for the
browser frontend. For a local machine, use the local setup section below.

The frontend JavaScript build requires the GHC JavaScript backend tools used by
the course setup:

```sh
javascript-unknown-ghcjs-ghc
javascript-unknown-ghcjs-ghc-pkg
```

The `forums-frontend/Makefile` calls `../js-cabal.nu`, and `js-cabal.nu` is configured
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

## Local Setup

If you are not using the course VM, you can install the JavaScript compiler
toolchain locally inside this `lab5` directory. This does not change your system
GHCup/Cabal setup or the other labs.

This requires `ghcup`, `git`, `nu`, and network access on the host machine.

From fish, bash, zsh, or any other non-Nushell shell, run the Nu scripts
explicitly from `lab5/`:

```sh
nu scripts/setup-js-toolchain.nu
nu scripts/build-frontend-js.nu
```

If you are already inside Nushell, you can run them directly:

```nu
scripts/setup-js-toolchain.nu
scripts/build-frontend-js.nu
```

For an interactive Nushell environment with the local toolchain on `PATH`, run:

```nu
source-env scripts/env-js-toolchain.nu
```

Do not `source` `scripts/env-js-toolchain.nu` from fish or bash; `source-env` is
a Nushell command.

The local setup uses:

```text
.toolhome/          local HOME for GHCup and Cabal
.emsdk/             local Emscripten checkout
dist-newstyle-js/   local Cabal build directory for the JS build
```

The default compiler is `javascript-unknown-ghcjs-9.10.2`. Older 9.6.x JavaScript
GHCs do not expose `GHC.JS.Foreign.Callback`, which `ghcjs-base-0.8.0.4`
requires. You can override the versions before setup:

```nu
$env.DAT_LAB5_JS_GHC_VERSION = 'javascript-unknown-ghcjs-9.10.2'
$env.DAT_LAB5_EMSDK_VERSION = '3.1.74'
scripts/setup-js-toolchain.nu
```

From another shell, pass overrides through `nu -c`:

```sh
nu -c '$env.DAT_LAB5_JS_GHC_VERSION = "javascript-unknown-ghcjs-9.10.2"; $env.DAT_LAB5_EMSDK_VERSION = "3.1.74"; scripts/setup-js-toolchain.nu'
```

## Build

If you ran the local setup above, the frontend is already built. To rebuild it
later from a non-Nushell shell:

```sh
nu scripts/build-frontend-js.nu
```

On the course VM, build all Haskell targets:

```sh
cabal build all
```

Then build the JavaScript frontend:

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
