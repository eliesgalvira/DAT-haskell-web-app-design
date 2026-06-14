#!/usr/bin/env nu

const script_dir = path self .
let root = ($script_dir | path join '..' | path expand)
let start_dir = (pwd)
let host_ghcup = ($env.GHCUP_BIN? | default { which ghcup | get 0.path? | default '' })

if ($host_ghcup | is-empty) {
  print -e 'ghcup is required on the host PATH to bootstrap the local lab5 toolchain.'
  exit 1
}

mkdir ($root | path join '.toolhome')

cd $script_dir
source-env env-js-toolchain.nu
cd $start_dir

if not (($env.EMSDK | path join '.git') | path exists) {
  ^git clone https://github.com/emscripten-core/emsdk.git $env.EMSDK
}

run-external ($env.EMSDK | path join 'emsdk') install $env.DAT_LAB5_EMSDK_VERSION
run-external ($env.EMSDK | path join 'emsdk') activate $env.DAT_LAB5_EMSDK_VERSION

# Keep the Nu environment aligned with the activated Emscripten checkout.
cd $script_dir
source-env env-js-toolchain.nu
cd $start_dir

let add_cross = (do { run-external $host_ghcup config add-release-channel cross } | complete)
if $add_cross.exit_code != 0 and not ($add_cross.stderr =~ 'already') {
  print -e $add_cross.stderr
  exit $add_cross.exit_code
}

^emconfigure $host_ghcup install ghc $env.DAT_LAB5_JS_GHC_VERSION --set
run-external $host_ghcup set ghc $env.DAT_LAB5_JS_GHC_VERSION

let ghc_version = ($env.DAT_LAB5_JS_GHC_VERSION | str replace 'javascript-unknown-ghcjs-' '')
let settings = (
  $env.HOME
  | path join '.ghcup' 'ghc' $env.DAT_LAB5_JS_GHC_VERSION 'lib' $"javascript-unknown-ghcjs-ghc-($ghc_version)" 'lib' 'settings'
)
if ($settings | path exists) {
  let js_cpp = ($env.EMSDK | path join 'upstream/emscripten/emcc')
  open $settings
  | str replace '("JavaScript CPP command", "")' $"(char lparen)\"JavaScript CPP command\", \"($js_cpp)\"(char rparen)"
  | str replace '("JavaScript CPP flags", "")' '("JavaScript CPP flags", "-E")'
  | save --force $settings
}

mkdir $env.CABAL_DIR
^cabal user-config init --force
^cabal update

print ''
print $"Local JavaScript toolchain is ready in ($root)"
print 'Use it with:'
print '  scripts/build-frontend-js.nu'
print ''
print 'For an interactive Nushell environment:'
print '  source-env scripts/env-js-toolchain.nu'
