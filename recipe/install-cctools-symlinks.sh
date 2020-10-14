prefix="${macos_machine}-"

pushd $PREFIX/bin
  for tool in $(ls ${prefix}*); do
    ln -s $PREFIX/bin/$tool $PREFIX/bin/${tool:${#prefix}} || true
  done
popd
