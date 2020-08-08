#!/bin/bash

set -x

# Ensure we do not end up linking to a shared libz
rm -f "${PREFIX}"/lib/libz*${SHLIB_EXT}
rm -f "${BUILD_PREFIX}"/lib/libz*${SHLIB_EXT}
# .. if this doesn't work we will need to pass LLVM_ENABLE_ZLIB
# or add find_library() to LLVM.

if [[ $target_platform == osx-64 ]]; then
  export CPU_COUNT=1
else
  export CC=$(which clang)
  export CXX=$(which clang++)
  export TCROOT=$CONDA_BUILD_SYSROOT
  ./tools/fix_unistd_issue.sh
fi
export cctools_cv_tapi_support=yes

pushd cctools
  LLVM_LTO_LIBRARY=$(find $PREFIX/lib -name "libLTO*${SHLIB_EXT}")
  LLVM_LTO_LIBRARY="$(basename $LLVM_LTO_LIBRARY)"
  sed -i.bak "s/libLTO.dylib/${LLVM_LTO_LIBRARY}/g" ld64/src/ld/InputFiles.cpp
  sed -i.bak "s/libLTO.dylib/${LLVM_LTO_LIBRARY}/g" libstuff/llvm.c
  sed -i.bak "s/libLTO.dylib/${LLVM_LTO_LIBRARY}/g" libstuff/lto.c
popd

# export CPPFLAGS="$CPPFLAGS -DCPU_SUBTYPE_ARM64_E=2"
export CXXFLAGS="$CXXFLAGS -O2 -gdwarf-4"
export CFLAGS="$CFLAGS -O2 -gdwarf-4"

pushd ${SRC_DIR}/cctools
  ./autogen.sh
popd

mkdir cctools_build_final
pushd cctools_build_final
  ${SRC_DIR}/cctools/configure \
    --prefix=${PREFIX} \
    --host=${HOST} \
    --build=${BUILD} \
    --target=${macos_machine} \
    --disable-static \
    --with-libtapi=${PREFIX} \
    --enable-shared || (cat config.log && cat config.status && false)
  cat config.log
  cat config.status
  make -j${CPU_COUNT} ${VERBOSE_AT} -k
popd
