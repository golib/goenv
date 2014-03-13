#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${GOENV_ROOT}/version" ]
  run rbenv-version-origin
  assert_success "${GOENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$GOENV_ROOT"
  touch "${GOENV_ROOT}/version"
  run rbenv-version-origin
  assert_success "${GOENV_ROOT}/version"
}

@test "detects RBENV_VERSION" {
  RBENV_VERSION=1 run rbenv-version-origin
  assert_success "RBENV_VERSION environment variable"
}

@test "detects local file" {
  touch .ruby-version
  run rbenv-version-origin
  assert_success "${PWD}/.ruby-version"
}

@test "detects alternate version file" {
  touch .rbenv-version
  run rbenv-version-origin
  assert_success "${PWD}/.rbenv-version"
}
