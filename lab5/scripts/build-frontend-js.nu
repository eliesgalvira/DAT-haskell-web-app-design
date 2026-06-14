#!/usr/bin/env nu

const script_dir = path self .

cd $script_dir
source-env env-js-toolchain.nu

if ((which javascript-unknown-ghcjs-ghc | is-empty)) {
  print -e 'Missing javascript-unknown-ghcjs-ghc. Run scripts/setup-js-toolchain.nu first.'
  exit 1
}

if ((which emcc | is-empty)) {
  print -e 'Missing emcc. Run scripts/setup-js-toolchain.nu first.'
  exit 1
}

cd ($env.DAT_LAB5_ROOT | path join 'forums-frontend')
^make clean
^make build
