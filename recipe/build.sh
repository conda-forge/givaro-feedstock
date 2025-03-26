#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./build-aux

export CFLAGS="-fPIC $CFLAGS"
export CXXFLAGS="-fPIC $CXXFLAGS"

autoreconf -vfi

chmod +x configure

# Enable only SSE/SSE2 as these are supported on all 64bit CPUs
# https://unix.stackexchange.com/a/249384
./configure \
    --prefix=$PREFIX \
    --libdir=$PREFIX/lib \
    --disable-doc \
    --enable-sse \
    --enable-sse2 \
    --disable-sse3 \
    --disable-ssse3 \
    --disable-sse41 \
    --disable-sse42 \
    --disable-avx \
    --disable-avx2 \
    --disable-fma \
    --disable-fma4 \
    --disable-static || (cat config.log; false)

make -j${CPU_COUNT} V=1
# Neet to do a make install first for the test suite
make install
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  make check || (cat tests/test-suite.log; false)
fi
