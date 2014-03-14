#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$GOENV_TEST_DIR"
  cd "$GOENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${GOENV_ROOT}/version" ]
  run goenv-version-origin
  assert_success "${GOENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$GOENV_ROOT"
  touch "${GOENV_ROOT}/version"
  run goenv-version-origin
  assert_success "${GOENV_ROOT}/version"
}

@test "detects local file" {
  touch .go-version
  run goenv-version-origin
  assert_success "${PWD}/.go-version"
}
