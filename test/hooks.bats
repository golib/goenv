#!/usr/bin/env bats

load test_helper

create_hook() {
  mkdir -p "$1/$2"
  touch "$1/$2/$3"
}

@test "prints usage help given no argument" {
  run goenv-hooks
  assert_failure "Usage: goenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${RBENV_TEST_DIR}/goenv.d"
  path2="${RBENV_TEST_DIR}/etc/goenv_hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path1" exec "ahoy.bash"
  create_hook "$path1" exec "invalid.sh"
  create_hook "$path1" which "boom.bash"
  create_hook "$path2" exec "bueno.bash"

  RBENV_HOOK_PATH="$path1:$path2" run goenv-hooks exec
  assert_success
  assert_output <<OUT
${RBENV_TEST_DIR}/goenv.d/exec/ahoy.bash
${RBENV_TEST_DIR}/goenv.d/exec/hello.bash
${RBENV_TEST_DIR}/etc/goenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${RBENV_TEST_DIR}/my hooks/goenv.d"
  path2="${RBENV_TEST_DIR}/etc/goenv hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path2" exec "ahoy.bash"

  RBENV_HOOK_PATH="$path1:$path2" run goenv-hooks exec
  assert_success
  assert_output <<OUT
${RBENV_TEST_DIR}/my hooks/goenv.d/exec/hello.bash
${RBENV_TEST_DIR}/etc/goenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  path="${RBENV_TEST_DIR}/goenv.d"
  create_hook "$path" exec "hello.bash"
  mkdir -p "$HOME"

  RBENV_HOOK_PATH="${HOME}/../goenv.d" run goenv-hooks exec
  assert_success "${RBENV_TEST_DIR}/goenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${RBENV_TEST_DIR}/goenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"

  RBENV_HOOK_PATH="$path" run goenv-hooks exec
  assert_success "${HOME}/hola.bash"
}
