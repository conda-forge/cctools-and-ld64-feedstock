#!/bin/bash

# Ensure we do not end up linking to a shared libz
rm -f "${PREFIX}"/lib/libz*${SHLIB_EXT}
rm -f "${BUILD_PREFIX}"/lib/libz*${SHLIB_EXT}
# .. if this doesn't work we will need to pass LLVM_ENABLE_ZLIB
# or add find_library() to LLVM.

export CC=$(which clang)
export CXX=$(which clang++)

if [[ $target_platform == osx-64 ]]; then
  export CPU_COUNT=1
else
  export TCROOT=$CONDA_BUILD_SYSROOT
  ./tools/fix_unistd_issue.sh
fi

#pushd cctools
#  if [[ ! -f configure ]]; then
#    autoreconf -vfi
#    # Yuck, sorry.
#    [[ -d include/macho-o ]] || mkdir -p include/macho-o
#    cp ld64/src/other/prune_trie.h include/mach-o/prune_trie.h
#    cp ld64/src/other/prune_trie.h libprunetrie/prune_trie.h
#    cp ld64/src/other/PruneTrie.cpp libprunetrie/PruneTrie.cpp
#  fi
#popd

export CPPFLAGS="$CPPFLAGS -DCPU_SUBTYPE_ARM64_E=2"
export CXXFLAGS="$CXXFLAGS -O2 -gdwarf-4"
export CFLAGS="$CFLAGS -O2 -gdwarf-4"

if [[ ${MACOSX_DEPLOYMENT_TARGET} == 10.10 ]]; then
  DARWIN_TARGET=x86_64-apple-darwin14.5.0
else
  DARWIN_TARGET=x86_64-apple-darwin13.4.0
fi

if [[ -z ${DARWIN_TARGET} ]]; then
  echo "Need a valid DARWIN_TARGET"
  exit 1
fi

declare -a _cctools_config
_cctools_config+=(--prefix=${PREFIX})
_cctools_config+=(--host=${HOST})
_cctools_config+=(--build=${BUILD})
_cctools_config+=(--target=${DARWIN_TARGET})
_cctools_config+=(--disable-static)
_cctools_config+=(--enable-shared)
_cctools_config+=(--with-llvm=${PREFIX})

mkdir cctools_build_final
pushd cctools_build_final
  ${SRC_DIR}/cctools/configure \
    --prefix=${PREFIX} \
    --host=${HOST} \
    --build=${BUILD} \
    --target=${DARWIN_TARGET} \
    --disable-static \
    --enable-shared \
    --with-llvm=${PREFIX}
  make -j${CPU_COUNT} ${VERBOSE_AT} -k
popd
