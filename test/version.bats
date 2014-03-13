#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${GOENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${GOENV_ROOT}/versions" ]
  run goenv-version
  assert_success "system (set by ${GOENV_ROOT}/version)"
}

@test "set by RBENV_VERSION" {
  create_version "1.9.3"
  RBENV_VERSION=1.9.3 run goenv-version
  assert_success "1.9.3 (set by RBENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "1.9.3"
  cat > ".ruby-version" <<<"1.9.3"
  run goenv-version
  assert_success "1.9.3 (set by ${PWD}/.ruby-version)"
}

@test "set by global file" {
  create_version "1.9.3"
  cat > "${GOENV_ROOT}/version" <<<"1.9.3"
  run goenv-version
  assert_success "1.9.3 (set by ${GOENV_ROOT}/version)"
}
