#!/usr/bin/env -S bash -euo pipefail

case "$TARGET" in
  *darwin*)
    # MacOS SDK ships bzip2
    export UNSUPPORTED=1
    exit 1
    ;;
esac

echo "Download bzip2..."
mkdir -p bzip2

# renovate: depName=https://gitlab.com/bzip2/bzip2.git
_commit='66c46b8c9436613fd81bc5d03f63a61933a4dcc3'

curl_tar "https://gitlab.com/bzip2/bzip2/-/archive/${_commit}/bzip2.tar.gz" bzip2 1

sed -i '/add_subdirectory(man)/d' bzip2/CMakeLists.txt

# Remove some superfluous files
rm -rf bzip2/{man,docs,tests,.gitlab*}

# Backup source
bak_src 'bzip2'

mkdir -p bzip2/build
cd bzip2/build

export CFLAGS="${CFLAGS:-} -DBZ_DEBUG=0"
export CXXFLAGS="${CXXFLAGS:-} -DBZ_DEBUG=0"

echo "Build bzip2..."
cmake \
  -DUSE_OLD_SONAME=On \
  -DENABLE_STATIC_LIB=On \
  -DENABLE_STATIC_LIB_IS_PIC=On \
  -DENABLE_APP=Off \
  -DENABLE_DOCS=Off \
  -DENABLE_TESTS=Off \
  -DENABLE_EXAMPLES=Off \
  -DENABLE_SHARED_LIB=Off \
  ..

ninja -j"$(nproc)"

ninja install

ln -s libbz2_static.a "${PREFIX}/lib/libbz2.a"
