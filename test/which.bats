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
  create_executable "1.8" "ruby"
  create_executable "2.0" "rspec"

  GOENV_VERSION=1.8 run goenv-which ruby
  assert_success "${GOENV_ROOT}/versions/1.8/bin/ruby"

  GOENV_VERSION=2.0 run goenv-which rspec
  assert_success "${GOENV_ROOT}/versions/2.0/bin/rspec"
}

@test "searches PATH for system version" {
  create_executable "${RBENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${GOENV_ROOT}/shims" "kill-all-humans"

  GOENV_VERSION=system run goenv-which kill-all-humans
  assert_success "${RBENV_TEST_DIR}/bin/kill-all-humans"
}

@test "version not installed" {
  create_executable "2.0" "rspec"
  GOENV_VERSION=1.9 run goenv-which rspec
  assert_failure "goenv: version \`1.9' is not installed"
}

@test "no executable found" {
  create_executable "1.8" "rspec"
  GOENV_VERSION=1.8 run goenv-which rake
  assert_failure "goenv: rake: command not found"
}

@test "executable found in other versions" {
  create_executable "1.8" "ruby"
  create_executable "1.9" "rspec"
  create_executable "2.0" "rspec"

  GOENV_VERSION=1.8 run goenv-which rspec
  assert_failure
  assert_output <<OUT
goenv: rspec: command not found

The \`rspec' command exists in these Ruby versions:
  1.9
  2.0
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${RBENV_TEST_DIR}/goenv.d"
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
