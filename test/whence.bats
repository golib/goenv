#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${GOENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "finds versions where present" {
  create_executable "1" "go"
  create_executable "1" "godoc"
  create_executable "1.2" "go"
  create_executable "1.2" "fix"

  run goenv-whence go
  assert_success
  assert_output <<OUT
1
1.2
OUT

  run goenv-whence godoc
  assert_success "1"

  run goenv-whence fix
  assert_success "1.2"
}
