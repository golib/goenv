#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${GOENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$GOENV_TEST_DIR"
  cd "$GOENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${GOENV_ROOT}/versions" ]
  run goenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  GOENV_VERSION=system run goenv-version-name
  assert_success "system"
}

@test "GOENV_VERSION has precedence over local" {
  create_version "1.2"
  create_version "1.2.1"

  cat > ".go-version" <<<"1.2"
  run goenv-version-name
  assert_success "1.2"

  GOENV_VERSION=1.2.1 run goenv-version-name
  assert_success "1.2.1"
}

@test "local file has precedence over global" {
  create_version "1.2"
  create_version "1.2.1"

  cat > "${GOENV_ROOT}/version" <<<"1.2"
  run goenv-version-name
  assert_success "1.2"

  cat > ".go-version" <<<"1.2.1"
  run goenv-version-name
  assert_success "1.2.1"
}

@test "missing version" {
  GOENV_VERSION=1.2 run goenv-version-name
  assert_failure "goenv: version \`1.2' is not installed"
}

@test "version with prefix in name" {
  create_version "1.2"
  cat > ".go-version" <<<"go-1.2"
  run goenv-version-name
  assert_success
  assert_output <<OUT
warning: ignoring extraneous \`go-' prefix in version \`go-1.2'
         (set by ${PWD}/.go-version)
1.2
OUT
}
