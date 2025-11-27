find "${RECIPE_DIR}" -name "*activate*.sh" -exec cp {} . \;

find . -name "*activate*.sh" -exec sed -i.bak "s|@CHOST@|${cross_macos_machine}|g" "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@TARGET_PLATFORM@|${cross_platform}|g"     "{}" \;

mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d/
cp "${SRC_DIR}"/activate.sh "${PREFIX}"/etc/conda/activate.d/activate_"${PKG_NAME}".sh
cp "${SRC_DIR}"/deactivate.sh "${PREFIX}"/etc/conda/deactivate.d/deactivate_"${PKG_NAME}".sh

