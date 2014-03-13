#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run rbenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${GOENV_ROOT}/shims"
  touch "${GOENV_ROOT}/shims/ruby"
  touch "${GOENV_ROOT}/shims/irb"
  run rbenv-shims
  assert_success
  assert_line "${GOENV_ROOT}/shims/ruby"
  assert_line "${GOENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${GOENV_ROOT}/shims"
  touch "${GOENV_ROOT}/shims/ruby"
  touch "${GOENV_ROOT}/shims/irb"
  run rbenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "ruby"
}
