#!/bin/bash
set -ex

if [[ $target_platform == osx-* ]]; then
  export CPU_COUNT=1
else
  export CC=$(which clang)
  export CXX=$(which clang++)
  export TCROOT=$CONDA_BUILD_SYSROOT
fi
export cctools_cv_tapi_support=yes

pushd cctools
  LLVM_LTO_LIBRARY=$(find $PREFIX/lib -name "libLTO.*.*")
  LLVM_LTO_LIBRARY="$(basename $LLVM_LTO_LIBRARY)"
  sed -i.bak "s/libLTO.dylib/${LLVM_LTO_LIBRARY}/g" ld64/src/ld/InputFiles.cpp
  sed -i.bak "s@llvm/libLTO.so@${LLVM_LTO_LIBRARY}@g" ld64/src/ld/InputFiles.cpp
  sed -i.bak "s/libLTO.so/${LLVM_LTO_LIBRARY}/g" ld64/src/ld/InputFiles.cpp
  sed -i.bak "s/libLTO.dylib/${LLVM_LTO_LIBRARY}/g" ld64/doc/man/man1/ld-classic.1
  sed -i.bak "s/libLTO.dylib/${LLVM_LTO_LIBRARY}/g" libstuff/llvm.c
  sed -i.bak "s/libLTO.so/${LLVM_LTO_LIBRARY}/g" libstuff/llvm.c
  sed -i.bak "s/libLTO.dylib/${LLVM_LTO_LIBRARY}/g" ld64/src/ld/parsers/lto_file.cpp
  sed -i.bak "s/libLTO.so/${LLVM_LTO_LIBRARY}/g" ld64/src/ld/parsers/lto_file.cpp
  sed -i.bak "s/libLTO.dylib/${LLVM_LTO_LIBRARY}/g" libstuff/lto.c
  sed -i.bak "s/libLTO.so/${LLVM_LTO_LIBRARY}/g" libstuff/lto.c
popd

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  # llvm-config from host env is tried by cctools-port
  # Move the build prefix one to host prefix
  rm $PREFIX/bin/llvm-config
  cp $BUILD_PREFIX/bin/llvm-config $PREFIX/bin/llvm-config
  rm $BUILD_PREFIX/bin/llvm-config
  if [[ "$build_platform" == osx-* ]]; then
      $INSTALL_NAME_TOOL -add_rpath "$BUILD_PREFIX/lib" $PREFIX/bin/llvm-config
  fi
fi

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
  make -j${CPU_COUNT} ${VERBOSE_AT}
popd
