#!/usr/bin/env bats

load test_helper

@test "default" {
  run rbenv global
  assert_success
  assert_output "system"
}

@test "read GOENV_ROOT/version" {
  mkdir -p "$GOENV_ROOT"
  echo "1.2.3" > "$GOENV_ROOT/version"
  run rbenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set GOENV_ROOT/version" {
  mkdir -p "$GOENV_ROOT/versions/1.2.3"
  run rbenv-global "1.2.3"
  assert_success
  run rbenv global
  assert_success "1.2.3"
}

@test "fail setting invalid GOENV_ROOT/version" {
  mkdir -p "$GOENV_ROOT"
  run rbenv-global "1.2.3"
  assert_failure "rbenv: version \`1.2.3' not installed"
}
