#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${RBENV_TEST_DIR}/myproject"
  cd "${RBENV_TEST_DIR}/myproject"
  echo "1.2.3" > .ruby-version
  RBENV_VERSION="" run goenv-sh-shell
  assert_failure "goenv: no shell-specific version configured"
}

@test "shell version" {
  RBENV_SHELL=bash RBENV_VERSION="1.2.3" run goenv-sh-shell
  assert_success 'echo "$RBENV_VERSION"'
}

@test "shell version (fish)" {
  RBENV_SHELL=fish RBENV_VERSION="1.2.3" run goenv-sh-shell
  assert_success 'echo "$RBENV_VERSION"'
}

@test "shell unset" {
  RBENV_SHELL=bash run goenv-sh-shell --unset
  assert_success "unset RBENV_VERSION"
}

@test "shell unset (fish)" {
  RBENV_SHELL=fish run goenv-sh-shell --unset
  assert_success "set -e RBENV_VERSION"
}

@test "shell change invalid version" {
  run goenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
goenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${GOENV_ROOT}/versions/1.2.3"
  RBENV_SHELL=bash run goenv-sh-shell 1.2.3
  assert_success 'export RBENV_VERSION="1.2.3"'
}

@test "shell change version (fish)" {
  mkdir -p "${GOENV_ROOT}/versions/1.2.3"
  RBENV_SHELL=fish run goenv-sh-shell 1.2.3
  assert_success 'setenv RBENV_VERSION "1.2.3"'
}
