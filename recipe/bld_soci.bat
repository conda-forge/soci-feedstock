mkdir build
cd build
if errorlevel 1 exit 1

set CMAKE_BACKEND_ARGS=-DSOCI_EMPTY=OFF -DSOCI_DB2=OFF -DSOCI_FIREBIRD=OFF ^
 -DSOCI_MYSQL=OFF -DSOCI_ODBC=OFF -DSOCI_ORACLE=OFF ^
 -DSOCI_POSTGRESQL=OFF -DSOCI_SQLITE3=OFF

if "%PKG_NAME%"=="soci-sqlite"     set CMAKE_BACKEND_ARGS=%CMAKE_BACKEND_ARGS% -DSOCI_SQLITE3=ON
if "%PKG_NAME%"=="soci-mysql"      set CMAKE_BACKEND_ARGS=%CMAKE_BACKEND_ARGS% -DSOCI_MYSQL=ON
if "%PKG_NAME%"=="soci-postgresql" set CMAKE_BACKEND_ARGS=%CMAKE_BACKEND_ARGS% -DSOCI_POSTGRESQL=ON

cmake %CMAKE_ARGS%                              ^
    -G "Ninja"                                  ^
    -DWITH_BOOST=OFF                            ^
    -DCMAKE_BUILD_TYPE=Release                  ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%     ^
    -DSOCI_LIBDIR=lib                           ^
    -DSOCI_STATIC=OFF                           ^
    -DSOCI_SQLITE3_BUILTIN=OFF                  ^
    -DSOCI_LTO=OFF                              ^
    -DSOCI_TESTS=OFF                            ^
    -DCMAKE_CXX_FLAGS=-DNOMINMAX                ^
    %CMAKE_BACKEND_ARGS%                        ^
    %SRC_DIR%
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
