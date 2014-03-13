#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${RBENV_TEST_DIR}/myproject"
  cd "${RBENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.ruby-version" ]
  run goenv-local
  assert_failure "goenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .ruby-version
  run goenv-local
  assert_success "1.2.3"
}

@test "supports legacy .goenv-version file" {
  echo "1.2.3" > .goenv-version
  run goenv-local
  assert_success "1.2.3"
}

@test "local .ruby-version has precedence over .goenv-version" {
  echo "1.8" > .goenv-version
  echo "2.0" > .ruby-version
  run goenv-local
  assert_success "2.0"
}

@test "ignores version in parent directory" {
  echo "1.2.3" > .ruby-version
  mkdir -p "subdir" && cd "subdir"
  run goenv-local
  assert_failure
}

@test "ignores GOENV_DIR" {
  echo "1.2.3" > .ruby-version
  mkdir -p "$HOME"
  echo "2.0-home" > "${HOME}/.ruby-version"
  GOENV_DIR="$HOME" run goenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${GOENV_ROOT}/versions/1.2.3"
  run goenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .ruby-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .ruby-version
  mkdir -p "${GOENV_ROOT}/versions/1.2.3"
  run goenv-local
  assert_success "1.0-pre"
  run goenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .ruby-version)" = "1.2.3" ]
}

@test "renames .goenv-version to .ruby-version" {
  echo "1.8.7" > .goenv-version
  mkdir -p "${GOENV_ROOT}/versions/1.9.3"
  run goenv-local
  assert_success "1.8.7"
  run goenv-local "1.9.3"
  assert_success
  assert_output <<OUT
goenv: removed existing \`.goenv-version' file and migrated
       local version specification to \`.ruby-version' file
OUT
  assert [ ! -e .goenv-version ]
  assert [ "$(cat .ruby-version)" = "1.9.3" ]
}

@test "doesn't rename .goenv-version if changing the version failed" {
  echo "1.8.7" > .goenv-version
  assert [ ! -e "${GOENV_ROOT}/versions/1.9.3" ]
  run goenv-local "1.9.3"
  assert_failure "goenv: version \`1.9.3' not installed"
  assert [ ! -e .ruby-version ]
  assert [ "$(cat .goenv-version)" = "1.8.7" ]
}

@test "unsets local version" {
  touch .ruby-version
  run goenv-local --unset
  assert_success ""
  assert [ ! -e .goenv-version ]
}

@test "unsets alternate version file" {
  touch .goenv-version
  run goenv-local --unset
  assert_success ""
  assert [ ! -e .goenv-version ]
}
