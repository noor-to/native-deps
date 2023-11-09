#!/usr/bin/env -S bash -euo pipefail

case "$TARGET" in
  *darwin* | aarch64-windows*)
    export UNSUPPORTED=1
    exit 1
    ;;
esac

echo "Download oneVPL..."
mkdir -p oneVPL

curl_tar 'https://github.com/oneapi-src/oneVPL/archive/refs/tags/v2023.3.1.tar.gz' oneVPL 1

for patch in "$PREFIX"/patches/*; do
  patch -F5 -lp1 -d oneVPL -t < "$patch"
done

sed -i '/add_subdirectory(examples)/d' oneVPL/CMakeLists.txt

# Remove unused components
rm -rf oneVPL/{.github,.style.yapf,.pylintrc,assets,script,doc,tools,examples}

# Backup source
bak_src 'oneVPL'

mkdir -p oneVPL/build
cd oneVPL/build

echo "Build oneVPL..."
cmake \
  -DBUILD_DEV=On \
  -DBUILD_TOOLS=Off \
  -DBUILD_TESTS=Off \
  -DBUILD_PREVIEW=Off \
  -DBUILD_EXAMPLES=Off \
  -DBUILD_DISPATCHER=On \
  -DINSTALL_EXAMPLE_CODE=Off \
  -DBUILD_TOOLS_ONEVPL_EXPERIMENTAL=Off \
  -DBUILD_DISPATCHER_ONEVPL_EXPERIMENTAL=Off \
  ..

ninja -j"$(nproc)"

ninja install
