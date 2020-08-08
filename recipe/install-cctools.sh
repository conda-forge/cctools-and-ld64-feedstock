#!/bin/bash

set -e

. activate "${BUILD_PREFIX}"
cd "${SRC_DIR}"

pushd cctools_build_final
  make install
popd

pushd "${PREFIX}"
  # This is packaged in ld64
  rm bin/*-ld
popd

if [[ "$use_llvm_tools" == "True" ]]; then
  rm -rf $PREFIX/libexec/as/$uname_machine
  mkdir -p $PREFIX/libexec/as/$uname_machine
  ln -sf $PREFIX/bin/llvm-as $PREFIX/libexec/as/$uname_machine/as

  for tool in ar as lipo nm ranlib size strip; do
     ln -sf $PREFIX/bin/llvm-$tool $PREFIX/bin/$macos_machine-$tool
  done
  ln -sf $PREFIX/bin/lld $PREFIX/bin/$macos_machine-ld64
fi
