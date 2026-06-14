#!/usr/bin/env nu

# Source this from Nushell with:
#   source-env scripts/env-js-toolchain.nu
#
# Executable wrapper scripts source it themselves. Running this file directly
# starts a child Nu process, so its environment changes cannot affect your
# parent shell.

const script_dir = path self .
let root = ($script_dir | path join '..' | path expand)
let real_home = ($env.DAT_LAB5_REAL_HOME? | default $env.HOME)
let home = ($root | path join '.toolhome')
let emsdk = ($root | path join '.emsdk')
let ghcup_bin = ($home | path join '.ghcup/bin')
let emscripten_bin = ($emsdk | path join 'upstream/emscripten')
let existing_path = if (($env.PATH | describe) =~ '^list') {
  $env.PATH
} else {
  $env.PATH | split row (char esep)
}

$env.DAT_LAB5_ROOT = $root
$env.DAT_LAB5_REAL_HOME = $real_home
$env.HOME = $home
$env.CABAL_DIR = ($home | path join '.cabal')
$env.CABAL_CONFIG = ($env.CABAL_DIR | path join 'config')
$env.EMSDK = $emsdk
$env.PATH = ([$ghcup_bin $emsdk $emscripten_bin] ++ $existing_path | uniq)
$env.DAT_LAB5_JS_GHC_VERSION = ($env.DAT_LAB5_JS_GHC_VERSION? | default 'javascript-unknown-ghcjs-9.10.2')
$env.DAT_LAB5_EMSDK_VERSION = ($env.DAT_LAB5_EMSDK_VERSION? | default '3.1.74')
$env.DAT_LAB5_DIST_DIR = ($root | path join 'dist-newstyle-js')
