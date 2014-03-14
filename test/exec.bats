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
  export GOENV_VERSION="2.0"
  run goenv-exec ruby -v
  assert_failure "goenv: version \`2.0' is not installed"
}

@test "completes with names of executables" {
  export GOENV_VERSION="2.0"
  create_executable "ruby" "#!/bin/sh"
  create_executable "rake" "#!/bin/sh"

  goenv-rehash
  run goenv-completions exec
  assert_success
  assert_output <<OUT
rake
ruby
OUT
}

@test "supports hook path with spaces" {
  hook_path="${RBENV_TEST_DIR}/custom stuff/goenv hooks"
  mkdir -p "${hook_path}/exec"
  echo "export HELLO='from hook'" > "${hook_path}/exec/hello.bash"

  export GOENV_VERSION=system
  GOENV_HOOK_PATH="$hook_path" run goenv-exec env
  assert_success
  assert_line "HELLO=from hook"
}

@test "carries original IFS within hooks" {
  hook_path="${RBENV_TEST_DIR}/goenv.d"
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
  export GOENV_VERSION="2.0"
  create_executable "ruby" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run goenv-exec ruby -w "/path to/ruby script.rb" -- extra args
  assert_success
  assert_output <<OUT
${GOENV_ROOT}/versions/2.0/bin/ruby
  -w
  /path to/ruby script.rb
  --
  extra
  args
OUT
}

@test "supports ruby -S <cmd>" {
  export GOENV_VERSION="2.0"

  # emulate `ruby -S' behavior
  create_executable "ruby" <<SH
#!$BASH
if [[ \$1 == "-S"* ]]; then
  found="\$(PATH="\${RUBYPATH:-\$PATH}" which \$2)"
  # assert that the found executable has ruby for shebang
  if head -1 "\$found" | grep ruby >/dev/null; then
    \$BASH "\$found"
  else
    echo "ruby: no Ruby script found in input (LoadError)" >&2
    exit 1
  fi
else
  echo 'ruby 2.0 (goenv test)'
fi
SH

  create_executable "rake" <<SH
#!/usr/bin/env ruby
echo hello rake
SH

  goenv-rehash
  run ruby -S rake
  assert_success "hello rake"
}
