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
  for tool in lipo nm size; do
     ln -sf $PREFIX/bin/llvm-$tool $PREFIX/bin/$macos_machine-$tool
  done
fi
