#!/bin/sh -ex

here=`cd "\`dirname \"$0\"\`";pwd`

deps="\
boost
cryptopp
eigen
firebreath
flann
g2o
jpeg
nite
opencv
opengm
openni
openssl
pcl
png
portaudio
primesensor
qhull
qt3d
qt
quazip
ruby
sensorkin4win
sensorkinect
stk
usb
vectorial
vtk
zlib
"

for dep in $deps; do
    $here/.move-submodule.sh $dep deps/$dep
done
