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

## Lab 3

These instructions start from the submitted archive `lab3.zip`.

### Requirements

You need `stack` installed.

Check it with:

```sh
stack --version
```

The first build may take a few minutes if Stack needs to download GHC or package
dependencies.

### Extract

Create a new directory for the extracted project and extract `lab3.zip` inside
it:

```sh
rm -rf lab3-build
mkdir lab3-build
unzip lab3.zip -d lab3-build
cd lab3-build
```

If you extract it with Windows Explorer, create a new folder first, for example
`lab3-build`, and extract `lab3.zip` into that folder. Then open a terminal in
the folder that contains `README.md`, `stack.yaml`, `wai-intro/`, and
`web-handler/`.

### Build

Build all Lab 3 executables:

```sh
stack build
```

### Run The Game

Run the Lab 3 game application:

```sh
stack run game
```

Open:

```text
http://localhost:4050
```

Stop the server with `Ctrl+C`.

If port `4050` is busy, use another port:

```powershell
$env:PORT = "4051"
stack run game
```

Then open:

```text
http://localhost:4051
```

On Linux or macOS, the equivalent command is:

```sh
PORT=4051 stack run game
```

### Quick Test

On the first visit in a new browser session, the page should show:

```text
Game state: (False,0)
```

Submit this string in the form:

```text
*+-++*--*+
```

The expected result is:

```text
Game state: (True,3)
```

The state is stored in a browser cookie. To restart from `(False,0)`, clear the
cookie for `localhost` or use a private/incognito browser window.

### Other Executable

The supplied `hello-2` example can also be run:

```sh
stack run hello-2
```

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

### Local Setup

If you are not using the course VM, install the JavaScript compiler toolchain
locally inside the `lab5` directory. This keeps GHCup, Cabal, Emscripten, and
the JavaScript build output scoped to Lab 5.

This requires `ghcup`, `git`, `nu`, and network access on the host machine.

From fish, bash, zsh, or any other non-Nushell shell, run:

```sh
cd lab5
nu scripts/setup-js-toolchain.nu
nu scripts/build-frontend-js.nu
```

If you are already inside Nushell, run:

```nu
cd lab5
scripts/setup-js-toolchain.nu
scripts/build-frontend-js.nu
```

The local setup uses:

```text
lab5/.toolhome/          local HOME for GHCup and Cabal
lab5/.emsdk/             local Emscripten checkout
lab5/dist-newstyle-js/   local Cabal build directory for the JS build
```

The default local compiler is `javascript-unknown-ghcjs-9.10.2` with
Emscripten `3.1.74`.

For an interactive Nushell environment with the local toolchain on `PATH`, run:

```nu
cd lab5
source-env scripts/env-js-toolchain.nu
```

Do not `source` `scripts/env-js-toolchain.nu` from fish or bash; `source-env` is
a Nushell command.

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

If you ran the local setup above, the frontend is already built. To rebuild it
later from a non-Nushell shell:

```sh
cd lab5
nu scripts/build-frontend-js.nu
```

On the course VM or in the extracted `dat-prj-5/` archive, build all native
Haskell targets:

```sh
cd dat-prj-5
cabal build all
```

Then build the JavaScript frontend:

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

The `browse` target uses `helium-browser` by default. If the VM uses a different
browser command, override it explicitly:

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

## Quick Run Cheat Sheet

These commands assume each lab has already been extracted, set up, and built.
Run them from the repository root unless a command says to open a second
terminal.

### Lab 1

```sh
cd lab1
./mps1 exercici1.txt
./mps2 exercici1.txt
./mps3 exercici1.txt
printf 'mul ( div ( mul 3 5) 7) ( sub 2 1)\n' > expressio.txt
./me expressio.txt
```

Expected result for the supplied stack-machine input is `2`.

### Lab 2

```sh
cd lab2/dat-prj
stack run life
```

Open the URL printed by the program, usually:

```text
http://localhost:3708/
```

Stop with `Ctrl+C`.

### Lab 3

```sh
cd lab3
stack run game
```

Open:

```text
http://localhost:4050
```

If `4050` is busy:

```sh
cd lab3
PORT=4051 stack run game
```

Then open `http://localhost:4051`. Stop with `Ctrl+C`.

### Lab 4

```sh
cd lab4
cabal run forums-app -- 4099
```

Open:

```text
http://127.0.0.1:4099/
```

Test users:

```text
usuari1 / 1234
usuari2 / 1234
```

Stop with `Ctrl+C`.

### Lab 5

Terminal 1, backend:

```sh
cd lab5/forums-backend
cabal run forums-backend -- 5001
```

Terminal 2, frontend static server:

```sh
cd lab5/forums-frontend
make serve
```

Open:

```text
http://localhost:8008/index.html
```

Because the frontend runs on `8008` and the backend runs on `5001`, normal
browsers may block API writes with CORS. For local testing, launch a separate
browser profile with web security disabled, for example:

```sh
helium-browser --disable-web-security --disable-site-isolation-trials \
  --user-data-dir=browse-user-data \
  http://localhost:8008/index.html
```

Or, if available:

```sh
chromium --disable-web-security --disable-site-isolation-trials \
  --user-data-dir=browse-user-data \
  http://localhost:8008/index.html
```

Stop both servers with `Ctrl+C` in their terminals.
