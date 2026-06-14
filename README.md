# DAT Labs

## Lab 1

These instructions start from the submitted archive `lab1.zip`.

### Requirements

You need GHC installed and available on `PATH`.

Lab 1 does not need Cabal or Stack. The PDF presents the lab as a set of
Haskell source files that can be compiled directly with GHC.

The archive contains the source files inside `lab1/`:

```text
lab1/
```

The submitted ZIP also contains `cabal.project` and `dat-labs.cabal` at the top
level. They are not required for Lab 1.

### Extract

Extract the archive into a new directory and enter the `lab1/` folder:

```sh
rm -rf lab1-build
mkdir lab1-build
unzip lab1.zip -d lab1-build
cd lab1-build/lab1
```

If you extract it with Windows Explorer, create a new folder first and extract
`lab1.zip` into that folder. Then open a terminal in the extracted `lab1`
folder, the one that contains `mps1.hs`, `mps2.hs`, `mps3.hs`, `me.hs`, and the
support modules.

### Build

Build the executables directly with GHC:

```sh
ghc --make mps1.hs -o mps1
ghc --make mps2.hs -o mps2
ghc --make mps3.hs -o mps3
ghc --make me.hs -o me
```

GHC creates intermediate `.hi` and `.o` files in the same directory. They can be
removed after the build if needed:

```sh
rm -f *.hi *.o
```

### Run

Each executable expects an input file path.

The ZIP includes `exercici1.txt`, which contains the stack-machine program from
the PDF:

```text
3 5 Mul 7 Div 2 1 Sub Mul
```

Run the stack-machine executables with that file:

```sh
./mps1 exercici1.txt
./mps2 exercici1.txt
./mps3 exercici1.txt
```

The expected result is `2`.

For `me`, create a text file with an expression like the one from the PDF:

```sh
printf 'mul ( div ( mul 3 5) 7) ( sub 2 1)\n' > expressio.txt
./me expressio.txt
```

On Windows, run the generated `.exe` files instead, for example:

```powershell
.\mps1.exe exercici1.txt
```

## Lab 2

These instructions start from the submitted archive `lab2.zip`.

### Requirements

You need `stack` installed.

The first build can take several minutes. The slow part is not the `life`
program itself, but the support stack needed to run the drawing app in a
browser.

Measured on this machine with GHC already installed but an empty Stack package
cache:

- `stack build --only-dependencies life` took about 351 seconds. This is the
  expensive part. Stack downloaded and indexed Hackage/Stackage metadata, then
  built the external browser/server dependencies: `miso`, `jsaddle`,
  `jsaddle-warp`, `warp`, `wai`, `websockets`, `servant`, `lens`, `aeson`,
  `cryptonite`, `http2`, `vector`, and many smaller packages.
- After those external dependencies existed, `stack build life` took about 17
  seconds. This built the local course libraries `drawing-core`,
  `jsaddle-warp-extra`, `drawing-activity`, and finally the `life` executable.
- Running `stack build life` again with nothing changed took about 0.3 seconds,
  because Stack reused the compiled cache.

If the GHC version selected by `resolver: lts-20.26` is not installed yet, Stack
may also need to install GHC before any of the timings above. That is another
one-time cost.

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

## Lab 4

These instructions start from the submitted archive `lab4.zip`.

### Requirements

You need GHC, Cabal, and `sqlite3` installed and available on `PATH`.

The archive includes the local `datfw-core` dependency in
`libs/datfw-core-0.2.0.0`, so it does not require files from Lab 2.

### Extract

Extract the archive and enter the extracted directory:

```sh
unzip lab4.zip -d lab4
cd lab4
```

If you extract it with Windows Explorer, open a terminal in the extracted folder
that contains `forums-app.cabal`, `cabal.project`, `src/`, `templates/`, and
`sqlite/`.

### Create Database

Create the SQLite database from the supplied SQL files:

```sh
rm -f forums.db
sqlite3 forums.db ".read sqlite/schema.sql"
sqlite3 forums.db ".read sqlite/users-data.sql"
sqlite3 forums.db ".read sqlite/forums-data.sql"
```

In PowerShell, use this equivalent first command:

```powershell
Remove-Item forums.db -ErrorAction SilentlyContinue
```

### Build And Run

Run the application:

```sh
cabal run forums-app -- 4099
```

Open:

```text
http://127.0.0.1:4099/
```

If port `4099` is busy, use another port:

```sh
cabal run forums-app -- 4100
```

Stop the server with `Ctrl+C`.

### Test Users

```text
usuari1 / 1234
usuari2 / 1234
```

### QA Checklist

1. Logged out, check that the home page, `/forums/1`, and `/topics/1` render.
2. Log in as `usuari1`.
3. Create a new forum from the home page.
4. Open that forum and create a new topic.
5. Open that topic and add a reply.
6. Check that topic and post counters update on the forum and home pages.
7. As the forum moderator, check that edit and delete controls are visible.
8. Log out, log in as `usuari2`, and check that this user can post but cannot
   edit or delete a forum created by `usuari1`.

To reset the test data, stop the server and rerun the database creation
commands above.

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
