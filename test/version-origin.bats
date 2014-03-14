#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
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

@test "detects GOENV_VERSION" {
  GOENV_VERSION=1 run goenv-version-origin
  assert_success "GOENV_VERSION environment variable"
}

@test "detects local file" {
  touch .go-version
  run goenv-version-origin
  assert_success "${PWD}/.go-version"
}

@test "detects alternate version file" {
  touch .goenv-version
  run goenv-version-origin
  assert_success "${PWD}/.goenv-version"
}
