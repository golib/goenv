#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run rbenv
  assert_success
  assert [ "${lines[0]}" = "rbenv 0.4.0" ]
}

@test "invalid command" {
  run rbenv does-not-exist
  assert_failure
  assert_output "rbenv: no such command \`does-not-exist'"
}

@test "default GOENV_ROOT" {
  GOENV_ROOT="" HOME=/home/mislav run rbenv root
  assert_success
  assert_output "/home/mislav/.rbenv"
}

@test "inherited GOENV_ROOT" {
  GOENV_ROOT=/opt/rbenv run rbenv root
  assert_success
  assert_output "/opt/rbenv"
}

@test "default GOENV_DIR" {
  run rbenv echo GOENV_DIR
  assert_output "$(pwd)"
}

@test "inherited GOENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  GOENV_DIR="$dir" run rbenv echo GOENV_DIR
  assert_output "$dir"
}

@test "invalid GOENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  GOENV_DIR="$dir" run rbenv echo GOENV_DIR
  assert_failure
  assert_output "rbenv: cannot change working directory to \`$dir'"
}
