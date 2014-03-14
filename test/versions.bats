#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${GOENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$GOENV_TEST_DIR"
  cd "$GOENV_TEST_DIR"
}

stub_system_go() {
  local stub="${GOENV_TEST_DIR}/bin/go"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_go
  assert [ ! -d "${GOENV_ROOT}/versions" ]
  run goenv-versions
  assert_success "* system (set by ${GOENV_ROOT}/version)"
}

@test "bare output no versions installed" {
  assert [ ! -d "${GOENV_ROOT}/versions" ]
  run goenv-versions --bare
  assert_success ""
}

@test "single version installed" {
  stub_system_go
  create_version "1.2"
  run goenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${GOENV_ROOT}/version)
  1.2
OUT
}

@test "single version bare" {
  create_version "1.2"
  run goenv-versions --bare
  assert_success "1.2"
}

@test "multiple versions" {
  stub_system_go
  create_version "1"
  create_version "1.2"
  create_version "1.2.1"
  run goenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${GOENV_ROOT}/version)
  1
  1.2
  1.2.1
OUT
}

@test "indicates current version" {
  stub_system_go
  create_version "1.2"
  create_version "1.2.1"
  GOENV_VERSION=1.2.1 run goenv-versions
  assert_success
  assert_output <<OUT
  system
  1.2
* 1.2.1 (set by GOENV_VERSION environment variable)
OUT
}

@test "bare doesn't indicate current version" {
  create_version "1.2"
  create_version "1.2.1"
  GOENV_VERSION=1.2.1 run goenv-versions --bare
  assert_success
  assert_output <<OUT
1.2
1.2.1
OUT
}

@test "globally selected version" {
  stub_system_go
  create_version "1.2"
  create_version "1.2.1"
  cat > "${GOENV_ROOT}/version" <<<"1.2.1"
  run goenv-versions
  assert_success
  assert_output <<OUT
  system
  1.2
* 1.2.1 (set by ${GOENV_ROOT}/version)
OUT
}

@test "per-project version" {
  stub_system_go
  create_version "1.2"
  create_version "1.2.1"
  cat > ".go-version" <<<"1.2.1"
  run goenv-versions
  assert_success
  assert_output <<OUT
  system
  1.2
* 1.2.1 (set by ${GOENV_TEST_DIR}/.go-version)
OUT
}
