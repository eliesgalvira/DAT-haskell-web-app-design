#!/usr/bin/env nu

def --wrapped main [...args] {
  let build_dir = ($env.DAT_LAB5_DIST_DIR? | default 'dist-newstyle')
  let build_dir_arg = $"--builddir=($build_dir)"

  ^cabal --with-compiler=javascript-unknown-ghcjs-ghc --with-hc-pkg=javascript-unknown-ghcjs-ghc-pkg $build_dir_arg ...$args
}
