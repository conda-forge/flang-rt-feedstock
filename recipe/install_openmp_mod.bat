@echo on

mkdir build_omp
cd build_omp

set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

:: remove other MSVC installs in the image that interfere
RMDIR /s /q "C:\Program Files\LLVM" || (echo Ignoring failure to delete C:\Program Files\LLVM)
RMDIR /s /q "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\Llvm" ^
    || (echo Ignoring failure to delete C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\Llvm)
RMDIR /s /q "C:\Program Files\Microsoft Visual Studio\2026\Enterprise\VC\Tools\Llvm" ^
    || (echo Ignoring failure to delete C:\Program Files\Microsoft Visual Studio\2026\Enterprise\VC\Tools\Llvm)

cmake -G "Ninja" %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -DLLVM_ENABLE_RUNTIMES=openmp,flang-rt ^
    -DLIBOMP_FORTRAN_MODULES=ON ^
    ../runtimes
if %ERRORLEVEL% neq 0 exit 1

cmake --build .
if %ERRORLEVEL% neq 0 exit 1

cmake --install .
if %ERRORLEVEL% neq 0 exit 1
