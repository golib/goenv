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
  run goenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  GOENV_VERSION=system run goenv-version-name
  assert_success "system"
}

@test "GOENV_VERSION has precedence over local" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > ".go-version" <<<"1.8.7"
  run goenv-version-name
  assert_success "1.8.7"

  GOENV_VERSION=1.9.3 run goenv-version-name
  assert_success "1.9.3"
}

@test "local file has precedence over global" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > "${GOENV_ROOT}/version" <<<"1.8.7"
  run goenv-version-name
  assert_success "1.8.7"

  cat > ".go-version" <<<"1.9.3"
  run goenv-version-name
  assert_success "1.9.3"
}

@test "missing version" {
  GOENV_VERSION=1.2 run goenv-version-name
  assert_failure "goenv: version \`1.2' is not installed"
}

@test "version with prefix in name" {
  create_version "1.8.7"
  cat > ".go-version" <<<"ruby-1.8.7"
  run goenv-version-name
  assert_success
  assert_output <<OUT
warning: ignoring extraneous \`ruby-' prefix in version \`ruby-1.8.7'
         (set by ${PWD}/.go-version)
1.8.7
OUT
}
