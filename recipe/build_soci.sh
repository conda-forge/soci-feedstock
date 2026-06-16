#!/bin/bash

rm -rf build

mkdir build; cd build

export CTEST_OUTPUT_ON_FAILURE=1

CMAKE_BACKEND_ARGS=(
  -DSOCI_EMPTY=OFF
  -DSOCI_DB2=OFF
  -DSOCI_FIREBIRD=OFF
  -DSOCI_MYSQL=OFF
  -DSOCI_ODBC=OFF
  -DSOCI_ORACLE=OFF
  -DSOCI_POSTGRESQL=OFF
  -DSOCI_SQLITE3=OFF
)

case "$PKG_NAME" in
  soci-sqlite)
    CMAKE_BACKEND_ARGS+=(-DSOCI_SQLITE3=ON)
    ;;
  soci-mysql)
    CMAKE_BACKEND_ARGS+=(-DSOCI_MYSQL=ON)
    ;;
  soci-postgresql)
    CMAKE_BACKEND_ARGS+=(-DSOCI_POSTGRESQL=ON)
    ;;
esac

cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX    \
      -G "Unix Makefiles"            \
      -DWITH_BOOST=OFF               \
      -DSOCI_CXX11=ON                \
      -DSOCI_LIBDIR=lib              \
      -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_LIBDIR=lib     \
      -DSOCI_STATIC=OFF              \
      "${CMAKE_BACKEND_ARGS[@]}"     \
      $SRC_DIR

make -j${CPU_COUNT}

if [[ (($PKG_NAME == *"sqlite" || $PKG_NAME == *"core")) && $ARCH != "arm64" ]]; then
  ctest --test-dir . --output-on-failure -j${CPU_COUNT}
fi
make install
