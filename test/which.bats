#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${GOENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "1" "go"
  create_executable "1.2.1" "godoc"

  GOENV_VERSION=1 run goenv-which go
  assert_success "${GOENV_ROOT}/versions/1/bin/go"

  GOENV_VERSION=1.2.1 run goenv-which godoc
  assert_success "${GOENV_ROOT}/versions/1.2.1/bin/godoc"
}

@test "searches PATH for system version" {
  create_executable "${GOENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${GOENV_ROOT}/shims" "kill-all-humans"

  GOENV_VERSION=system run goenv-which kill-all-humans
  assert_success "${GOENV_TEST_DIR}/bin/kill-all-humans"
}

@test "version not installed" {
  create_executable "1.2.1" "go"
  GOENV_VERSION=1 run goenv-which rspec
  assert_failure "goenv: version \`1' is not installed"
}

@test "no executable found" {
  create_executable "1" "cover"
  GOENV_VERSION=1 run goenv-which go
  assert_failure "goenv: go: command not found"
}

@test "executable found in other versions" {
  create_executable "1" "go"
  create_executable "1.2" "fix"
  create_executable "1.2.1" "fix"

  GOENV_VERSION=1 run goenv-which fix
  assert_failure
  assert_output <<OUT
goenv: fix: command not found

The \`fix' command exists in these Golang versions:
  1.2
  1.2.1
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${GOENV_TEST_DIR}/goenv.d"
  mkdir -p "${hook_path}/which"
  cat > "${hook_path}/which/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  GOENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run goenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}
