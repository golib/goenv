#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${GOENV_ROOT}/version" ]
  assert [ ! -e ".ruby-version" ]
  run goenv-version-file
  assert_success "${GOENV_ROOT}/version"
}

@test "detects 'global' file" {
  create_file "${GOENV_ROOT}/global"
  run goenv-version-file
  assert_success "${GOENV_ROOT}/global"
}

@test "detects 'default' file" {
  create_file "${GOENV_ROOT}/default"
  run goenv-version-file
  assert_success "${GOENV_ROOT}/default"
}

@test "'version' has precedence over 'global' and 'default'" {
  create_file "${GOENV_ROOT}/version"
  create_file "${GOENV_ROOT}/global"
  create_file "${GOENV_ROOT}/default"
  run goenv-version-file
  assert_success "${GOENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".ruby-version"
  run goenv-version-file
  assert_success "${RBENV_TEST_DIR}/.ruby-version"
}

@test "legacy file in current directory" {
  create_file ".goenv-version"
  run goenv-version-file
  assert_success "${RBENV_TEST_DIR}/.goenv-version"
}

@test ".ruby-version has precedence over legacy file" {
  create_file ".ruby-version"
  create_file ".goenv-version"
  run goenv-version-file
  assert_success "${RBENV_TEST_DIR}/.ruby-version"
}

@test "in parent directory" {
  create_file ".ruby-version"
  mkdir -p project
  cd project
  run goenv-version-file
  assert_success "${RBENV_TEST_DIR}/.ruby-version"
}

@test "topmost file has precedence" {
  create_file ".ruby-version"
  create_file "project/.ruby-version"
  cd project
  run goenv-version-file
  assert_success "${RBENV_TEST_DIR}/project/.ruby-version"
}

@test "legacy file has precedence if higher" {
  create_file ".ruby-version"
  create_file "project/.goenv-version"
  cd project
  run goenv-version-file
  assert_success "${RBENV_TEST_DIR}/project/.goenv-version"
}

@test "GOENV_DIR has precedence over PWD" {
  create_file "widget/.ruby-version"
  create_file "project/.ruby-version"
  cd project
  GOENV_DIR="${RBENV_TEST_DIR}/widget" run goenv-version-file
  assert_success "${RBENV_TEST_DIR}/widget/.ruby-version"
}

@test "PWD is searched if GOENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.ruby-version"
  cd project
  GOENV_DIR="${RBENV_TEST_DIR}/widget/blank" run goenv-version-file
  assert_success "${RBENV_TEST_DIR}/project/.ruby-version"
}
