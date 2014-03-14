#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run goenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${GOENV_ROOT}/shims"
  touch "${GOENV_ROOT}/shims/go"
  touch "${GOENV_ROOT}/shims/fix"
  run goenv-shims
  assert_success
  assert_line "${GOENV_ROOT}/shims/go"
  assert_line "${GOENV_ROOT}/shims/fix"
}

@test "shims --short" {
  mkdir -p "${GOENV_ROOT}/shims"
  touch "${GOENV_ROOT}/shims/go"
  touch "${GOENV_ROOT}/shims/fix"
  run goenv-shims --short
  assert_success
  assert_line "fix"
  assert_line "go"
}
