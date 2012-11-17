#!/bin/sh -e

echo "This is a migration script. And it's been fired already."
exit

here=`cd "\`dirname \"$0\"\`";pwd` ; source "$here/cmd.sh" ; cd "$here/.."

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
    cmds/move-submodule.sh $dep deps/$dep
done
