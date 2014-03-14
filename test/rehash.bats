#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${GOENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${GOENV_ROOT}/shims" ]
  run goenv-rehash
  assert_success ""
  assert [ -d "${GOENV_ROOT}/shims" ]
  rmdir "${GOENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${GOENV_ROOT}/shims"
  chmod -w "${GOENV_ROOT}/shims"
  run goenv-rehash
  assert_failure "goenv: cannot rehash: ${GOENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${GOENV_ROOT}/shims"
  touch "${GOENV_ROOT}/shims/.goenv-shim"
  run goenv-rehash
  assert_failure "goenv: cannot rehash: ${GOENV_ROOT}/shims/.goenv-shim exists"
}

@test "creates shims" {
  create_executable "1" "go"
  create_executable "1" "cover"
  create_executable "1.2" "go"
  create_executable "1.2" "cover"

  assert [ ! -e "${GOENV_ROOT}/shims/go" ]
  assert [ ! -e "${GOENV_ROOT}/shims/cover" ]

  run goenv-rehash
  assert_success ""

  run ls "${GOENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
cover
go
OUT
}

@test "removes stale shims" {
  mkdir -p "${GOENV_ROOT}/shims"
  touch "${GOENV_ROOT}/shims/oldshim1"
  chmod +x "${GOENV_ROOT}/shims/oldshim1"

  create_executable "1.2" "godoc"
  create_executable "1.2" "go"

  run goenv-rehash
  assert_success ""

  assert [ ! -e "${GOENV_ROOT}/shims/oldshim1" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 1" "go"
  create_executable "dirname2 1.2.1" "cover"

  assert [ ! -e "${GOENV_ROOT}/shims/go" ]
  assert [ ! -e "${GOENV_ROOT}/shims/rspec" ]

  run goenv-rehash
  assert_success ""

  run ls "${GOENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
cover
go
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${GOENV_TEST_DIR}/goenv.d"
  mkdir -p "${hook_path}/rehash"
  cat > "${hook_path}/rehash/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  GOENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run goenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "1.2.1" "go"
  GOENV_SHELL=bash run goenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${GOENV_ROOT}/shims/go" ]
}

@test "sh-rehash in fish" {
  create_executable "1.2.1" "go"
  GOENV_SHELL=fish run goenv-sh-rehash
  assert_success ""
  assert [ -x "${GOENV_ROOT}/shims/go" ]
}
