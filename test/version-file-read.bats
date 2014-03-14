#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${GOENV_TEST_DIR}/myproject"
  cd "${GOENV_TEST_DIR}/myproject"
}

@test "fails without arguments" {
  run goenv-version-file-read
  assert_failure ""
}

@test "fails for invalid file" {
  run goenv-version-file-read "non-existent"
  assert_failure ""
}

@test "fails for blank file" {
  echo > my-version
  run goenv-version-file-read my-version
  assert_failure ""
}

@test "reads simple version file" {
  cat > my-version <<<"1.2.1"
  run goenv-version-file-read my-version
  assert_success "1.2.1"
}

@test "ignores leading spaces" {
  cat > my-version <<<"  1.2.1"
  run goenv-version-file-read my-version
  assert_success "1.2.1"
}

@test "reads only the first word from file" {
  cat > my-version <<<"1.2.1@tag 1 hi"
  run goenv-version-file-read my-version
  assert_success "1.2.1@tag"
}

@test "loads only the first line in file" {
  cat > my-version <<IN
1.2 one
1.2.1 two
IN
  run goenv-version-file-read my-version
  assert_success "1.2"
}

@test "ignores leading blank lines" {
  cat > my-version <<IN

1.2.1
IN
  run goenv-version-file-read my-version
  assert_success "1.2.1"
}

@test "handles the file with no trailing newline" {
  echo -n "1.2" > my-version
  run goenv-version-file-read my-version
  assert_success "1.2"
}
