@echo on

:: set compilers to clang-cl; MSVC doesn't like __attribute__
set "CC=clang-cl"
set "CXX=clang-cl"

:: remove other MSVC installs in the image that interfere
RMDIR /s /q "C:\Program Files\LLVM" || (echo Ignoring failure to delete C:\Program Files\LLVM)
RMDIR /s /q "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\Llvm" ^
    || (echo Ignoring failure to delete C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\Llvm)
RMDIR /s /q "C:\Program Files\Microsoft Visual Studio\2026\Enterprise\VC\Tools\Llvm" ^
    || (echo Ignoring failure to delete C:\Program Files\Microsoft Visual Studio\2026\Enterprise\VC\Tools\Llvm)

mkdir build
cd build

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_CXX_STANDARD=17 ^
    -DCMAKE_EXPORT_COMPILE_COMMANDS=OFF ^
    -DCMAKE_Fortran_COMPILER=%BUILD_PREFIX%/Library/bin/flang.exe ^
    -DCMAKE_Fortran_COMPILER_WORKS=yes ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_MODULE_PATH=../cmake/Modules ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%;%LIBRARY_LIB%/clang/%PKG_VERSION% ^
    -DLLVM_EXTERNAL_LIT=%LIBRARY_BIN%/lit ^
    -DLLVM_LIT_ARGS=-v ^
    -DLLVM_CMAKE_DIR=%LIBRARY_LIB%/cmake/llvm ^
    -DLLVM_DIR=%LIBRARY_LIB%/cmake/llvm ^
    -DLLVM_ENABLE_RUNTIMES="openmp,flang-rt" ^
    -DClang_DIR=%LIBRARY_PREFIX% ^
    -DFLANG_RT_INCLUDE_TESTS=OFF ^
    -DLIBOMP_FORTRAN_MODULES=ON ^
    ..\runtimes
if %ERRORLEVEL% neq 0 exit 1

cmake --build . -j2
if %ERRORLEVEL% neq 0 exit 1

cmake --install .
if %ERRORLEVEL% neq 0 exit 1
