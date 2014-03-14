#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${RBENV_TEST_DIR}/myproject"
  cd "${RBENV_TEST_DIR}/myproject"
  echo "1.2.3" > .ruby-version
  mkdir -p "${GOENV_ROOT}/versions/1.2.3"
  run goenv-prefix
  assert_success "${GOENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  GOENV_VERSION="1.2.3" run goenv-prefix
  assert_failure "goenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${RBENV_TEST_DIR}/bin"
  touch "${RBENV_TEST_DIR}/bin/ruby"
  chmod +x "${RBENV_TEST_DIR}/bin/ruby"
  GOENV_VERSION="system" run goenv-prefix
  assert_success "$RBENV_TEST_DIR"
}

@test "prefix for invalid system" {
  PATH="$(path_without ruby)" run goenv-prefix system
  assert_failure "goenv: system version not found in PATH"
}
