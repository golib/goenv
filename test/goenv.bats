#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run goenv
  assert_success
  assert [ "${lines[0]}" = "goenv 0.4.0" ]
}

@test "invalid command" {
  run goenv does-not-exist
  assert_failure
  assert_output "goenv: no such command \`does-not-exist'"
}

@test "default GOENV_ROOT" {
  GOENV_ROOT="" HOME=/home/mislav run goenv root
  assert_success
  assert_output "/home/mislav/.goenv"
}

@test "inherited GOENV_ROOT" {
  GOENV_ROOT=/opt/goenv run goenv root
  assert_success
  assert_output "/opt/goenv"
}

@test "default GOENV_DIR" {
  run goenv echo GOENV_DIR
  assert_output "$(pwd)"
}

@test "inherited GOENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  GOENV_DIR="$dir" run goenv echo GOENV_DIR
  assert_output "$dir"
}

@test "invalid GOENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  GOENV_DIR="$dir" run goenv echo GOENV_DIR
  assert_failure
  assert_output "goenv: cannot change working directory to \`$dir'"
}
