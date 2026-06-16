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
    # Workaround for SOCI 4.1.3 FindMySQL.cmake bug: pkg_search_module fails
    # to find the conda-forge MySQL pkg-config module (name mismatch), causing
    # the mysql_config --libs fallback to run. That stores raw -L/-l flags in
    # MySQL_LIBRARIES, which then gets passed to IMPORTED_LOCATION — a property
    # that expects a single file path, not a linker flag list.
    # Pre-setting MySQL_LIBRARIES to the actual .so path bypasses that code path.
    _mlib=$(find "$PREFIX/lib" -maxdepth 2 \
              \( -name 'libmysqlclient.so' -o -name 'libmariadb.so' \) \
              2>/dev/null | head -1)
    _minc=$(mysql_config --include 2>/dev/null | sed 's/^[[:space:]]*-I//')
    [[ -n "$_mlib" ]] && CMAKE_BACKEND_ARGS+=(-DMySQL_LIBRARIES="$_mlib")
    [[ -n "$_minc" ]] && CMAKE_BACKEND_ARGS+=(-DMySQL_INCLUDE_DIRS="$_minc")
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
      -DSOCI_LTO=OFF                 \
      "${CMAKE_BACKEND_ARGS[@]}"     \
      $SRC_DIR

make -j${CPU_COUNT}

if [[ (($PKG_NAME == *"sqlite" || $PKG_NAME == *"core")) && $ARCH != "arm64" ]]; then
  ctest --test-dir . --output-on-failure -j${CPU_COUNT}
fi
make install
