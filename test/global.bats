#!/usr/bin/env bats

load test_helper

@test "default" {
  run goenv global
  assert_success
  assert_output "system"
}

@test "read GOENV_ROOT/version" {
  mkdir -p "$GOENV_ROOT"
  echo "1.2.1" > "$GOENV_ROOT/version"
  run goenv-global
  assert_success
  assert_output "1.2.1"
}

@test "set GOENV_ROOT/version" {
  mkdir -p "$GOENV_ROOT/versions/1.2.1"
  run goenv-global "1.2.1"
  assert_success
  run goenv global
  assert_success "1.2.1"
}

@test "fail setting invalid GOENV_ROOT/version" {
  mkdir -p "$GOENV_ROOT"
  run goenv-global "1.2.1"
  assert_failure "goenv: version \`1.2.1' not installed"
}
