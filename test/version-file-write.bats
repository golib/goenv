#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run goenv-version-file-write
  assert_failure "Usage: goenv version-file-write <file> <version>"
  run goenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".go-version" ]
  run goenv-version-file-write ".go-version" "1.8.7"
  assert_failure "goenv: version \`1.8.7' not installed"
  assert [ ! -e ".go-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${GOENV_ROOT}/versions/1.8.7"
  assert [ ! -e "my-version" ]
  run goenv-version-file-write "${PWD}/my-version" "1.8.7"
  assert_success ""
  assert [ "$(cat my-version)" = "1.8.7" ]
}
