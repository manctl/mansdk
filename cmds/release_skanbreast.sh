#!/bin/sh -e

here=`cd "\`dirname \"$0\"\`";pwd` ; source "$here/cmd.sh" ; cd "$here/.."

# Example: release_skanbreast.sh skanbreast-1.0
# Note: do not forget to run make install before

if test $# -ne 1; then
    echo "Usage: $0 dirname"
    exit 1
fi

dir=$1
stage=`pwd`/stage/relwithdebinfo

mkdir -p $dir
cd $dir
mkdir bin lib lib64
cd bin
cp -a $stage/bin/{skanbreast,rgbd-multikinect,rgbd-viewer} .
strip *
cp -ra $stage/bin/config .
cd ../lib
cp -a $stage/lib/*.so* .
strip *
cd ../lib64
cp -a $stage/lib64/*.so* .
strip *
cd ../..
tar cvfj ${dir}.tar.bz2 $dir
