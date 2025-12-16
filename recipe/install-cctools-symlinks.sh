prefix="${cross_macos_machine}-"

pushd $PREFIX/bin
  for tool in $(ls ${prefix}*); do
    # libtool conflicts with autotool's libtool
    [[ "${tool}" == "${prefix}libtool" ]] && continue;
    ln -s $PREFIX/bin/$tool $PREFIX/bin/${tool:${#prefix}} || true
  done
popd
