#!/bin/sh

for d in boost eigen flann jpeg opencv openni nite pcl usb vtk; do
    cd $d
    git checkout --track -b manctl remotes/origin/manctl || git checkout manctl
    cd ..
done

cd qhull
git checkout --track -b master remotes/origin/master
cd ..

cd primesensor
git checkout --track -b manctl-primesensor-unstable remotes/origin/manctl-primesensor-unstable
cd ..

cd sensorkinect
git checkout --track -b manctl-sensorkinect-unstable remotes/origin/manctl-sensorkinect-unstable
cd ..
