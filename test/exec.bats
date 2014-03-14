#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${GOENV_ROOT}/versions/${GOENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export GOENV_VERSION="1.2"
  run goenv-exec go -v
  assert_failure "goenv: version \`1.2' is not installed"
}

@test "completes with names of executables" {
  export GOENV_VERSION="1.2"
  create_executable "go" "#!/bin/sh"
  create_executable "cover" "#!/bin/sh"

  goenv-rehash
  run goenv-completions exec
  assert_success
  assert_output <<OUT
cover
go
OUT
}

@test "supports hook path with spaces" {
  hook_path="${GOENV_TEST_DIR}/custom stuff/goenv hooks"
  mkdir -p "${hook_path}/exec"
  echo "export HELLO='from hook'" > "${hook_path}/exec/hello.bash"

  export GOENV_VERSION=system
  GOENV_HOOK_PATH="$hook_path" run goenv-exec env
  assert_success
  assert_line "HELLO=from hook"
}

@test "carries original IFS within hooks" {
  hook_path="${GOENV_TEST_DIR}/goenv.d"
  mkdir -p "${hook_path}/exec"
  cat > "${hook_path}/exec/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export GOENV_VERSION=system
  GOENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run goenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export GOENV_VERSION="1.2"
  create_executable "go" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run goenv-exec go -w "/path to/go script.rb" -- extra args
  assert_success
  assert_output <<OUT
${GOENV_ROOT}/versions/1.2/bin/go
  -w
  /path to/go script.rb
  --
  extra
  args
OUT
}

@test "supports go -S <cmd>" {
  export GOENV_VERSION="1.2"

  # emulate `go -S' behavior
  create_executable "go" <<SH
#!$BASH
if [[ \$1 == "-S"* ]]; then
  found="\$(PATH="\${GOPATH:-\$PATH}" which \$2)"
  # assert that the found executable has go for shebang
  if head -1 "\$found" | grep go >/dev/null; then
    \$BASH "\$found"
  else
    echo "go: no Golang script found in input (LoadError)" >&2
    exit 1
  fi
else
  echo 'go 1.2 (goenv test)'
fi
SH

  create_executable "fix" <<SH
#!/usr/bin/env go
echo hello fix
SH

  goenv-rehash
  run go -S fix
  assert_success "hello fix"
}
