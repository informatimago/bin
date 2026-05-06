#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=${TMPDIR:-/tmp}/distribution-tests-$$

cleanup(){
    rm -rf "$tmp"
}
trap cleanup EXIT

mkdir -p "$tmp/root/etc"

cat > "$tmp/root/etc/os-release" <<'EOF'
NAME=MSYS2
ID=msys2
PRETTY_NAME="MSYS2"
ID_LIKE="cygwin arch"
HOME_URL="https://www.msys2.org"
BUG_REPORT_URL="https://github.com/msys2/MSYS2-packages/issues"
EOF

got=$(DISTRIBUTION_TEST_UNAME_O=Msys \
      DISTRIBUTION_TEST_UNAME_R=3.5.4.x86_64 \
      DISTRIBUTION_TEST_UNAME=MINGW64_NT-10.0-26200 \
      bash "$script_dir/distribution" "$tmp/root")
expected='Msys msys2 3.5.4.x86_64  '
if [ "$got" != "$expected" ] ; then
    printf 'MSYS2 distribution test failed.\nexpected: <%s>\n     got: <%s>\n' "$expected" "$got" >&2
    exit 1
fi

got=$(DISTRIBUTION_TEST_UNAME_O=Msys \
      DISTRIBUTION_TEST_UNAME_R=3.5.4.x86_64 \
      DISTRIBUTION_TEST_UNAME=MINGW64_NT-10.0-26200 \
      bash "$script_dir/distribution" -i "$tmp/root")
expected='msys2-3.5.4.x86_64'
if [ "$got" != "$expected" ] ; then
    printf 'MSYS2 distribution -i test failed.\nexpected: <%s>\n     got: <%s>\n' "$expected" "$got" >&2
    exit 1
fi

printf 'distribution MSYS2 tests passed.\n'

darwin_root="$tmp/darwin-root"
mkdir -p "$darwin_root/System/Library/Frameworks/AppKit.framework"
touch "$darwin_root/System/Library/Frameworks/AppKit.framework/AppKit"

got=$(DISTRIBUTION_TEST_UNAME=Darwin \
      DISTRIBUTION_TEST_HOSTINFO='Darwin Kernel Version 24.6.0: Mon Jul 14 11:28:17 PDT 2025; root:xnu/xnu-11417.140.69~1/RELEASE_ARM64_T6000' \
      bash "$script_dir/distribution" "$darwin_root")
expected='Darwin apple 24.6.0 Sequoia macOS_v15.7.5'
if [ "$got" != "$expected" ] ; then
    printf 'Darwin Sequoia distribution test failed.\nexpected: <%s>\n     got: <%s>\n' "$expected" "$got" >&2
    exit 1
fi

printf 'distribution Darwin Sequoia tests passed.\n'
