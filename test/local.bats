#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${GOENV_TEST_DIR}/myproject"
  cd "${GOENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.go-version" ]
  run goenv-local
  assert_failure "goenv: no local version configured for current directory"
}

@test "local version" {
  echo "1.2.1" > .go-version
  run goenv-local
  assert_success "1.2.1"
}

@test "ignores version in parent directory" {
  echo "1.2.1" > .go-version
  mkdir -p "subdir" && cd "subdir"
  run goenv-local
  assert_failure
}

@test "ignores GOENV_DIR" {
  echo "1.2.1" > .go-version
  mkdir -p "$HOME"
  echo "2.0-home" > "${HOME}/.go-version"
  GOENV_DIR="$HOME" run goenv-local
  assert_success "1.2.1"
}

@test "sets local version" {
  mkdir -p "${GOENV_ROOT}/versions/1.2.1"
  run goenv-local 1.2.1
  assert_success ""
  assert [ "$(cat .go-version)" = "1.2.1" ]
}

@test "changes local version" {
  echo "1.2" > .go-version
  mkdir -p "${GOENV_ROOT}/versions/1.2.1"
  run goenv-local
  assert_success "1.2"
  run goenv-local 1.2.1
  assert_success ""
  assert [ "$(cat .go-version)" = "1.2.1" ]
}
