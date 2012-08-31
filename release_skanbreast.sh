#!/bin/bash

dir=$1
stage=`pwd`/stage/relwithdebinfo

mkdir -p $dir
cd $dir
mkdir bin lib lib64
cd bin
cp $stage/bin/{skanbreast,rgbd-multikinect,rgbd-viewer} .
strip *
cp -r $stage/bin/config .
cd ../lib
cp $stage/lib/*.so* .
strip *
cd ../lib64
cp $stage/lib64/*.so* .
strip *
cd ../..
tar cvfz ${dir}.tar.bz2 $dir
