#!/bin/bash

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
tar cvfz ${dir}.tar.bz2 $dir
