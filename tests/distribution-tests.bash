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
