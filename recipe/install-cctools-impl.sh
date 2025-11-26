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

ln -sf ${PREFIX}/bin/dsymutil ${PREFIX}/bin/${cross_macos_machine}-dsymutil
ln -sf ${PREFIX}/bin/llvm-cxxfilt ${PREFIX}/bin/${cross_macos_machine}-c++filt
