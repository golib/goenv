#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${GOENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

stub_system_ruby() {
  local stub="${RBENV_TEST_DIR}/bin/ruby"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_ruby
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
  stub_system_ruby
  create_version "1.9"
  run goenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${GOENV_ROOT}/version)
  1.9
OUT
}

@test "single version bare" {
  create_version "1.9"
  run goenv-versions --bare
  assert_success "1.9"
}

@test "multiple versions" {
  stub_system_ruby
  create_version "1.8.7"
  create_version "1.9.3"
  create_version "2.0.0"
  run goenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${GOENV_ROOT}/version)
  1.8.7
  1.9.3
  2.0.0
OUT
}

@test "indicates current version" {
  stub_system_ruby
  create_version "1.9.3"
  create_version "2.0.0"
  GOENV_VERSION=1.9.3 run goenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by GOENV_VERSION environment variable)
  2.0.0
OUT
}

@test "bare doesn't indicate current version" {
  create_version "1.9.3"
  create_version "2.0.0"
  GOENV_VERSION=1.9.3 run goenv-versions --bare
  assert_success
  assert_output <<OUT
1.9.3
2.0.0
OUT
}

@test "globally selected version" {
  stub_system_ruby
  create_version "1.9.3"
  create_version "2.0.0"
  cat > "${GOENV_ROOT}/version" <<<"1.9.3"
  run goenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${GOENV_ROOT}/version)
  2.0.0
OUT
}

@test "per-project version" {
  stub_system_ruby
  create_version "1.9.3"
  create_version "2.0.0"
  cat > ".go-version" <<<"1.9.3"
  run goenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${RBENV_TEST_DIR}/.go-version)
  2.0.0
OUT
}
