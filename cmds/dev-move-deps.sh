#!/bin/sh -ex

here=`cd "\`dirname \"$0\"\`";pwd` ; source "$here/cmd.sh" ; cd "$here/.."

echo "This is just a submodule moving developement rig."
exit 0;

true \
    && git reset --hard \
    && rm -rf deps \
    && git submodule init \
    && git submodule update \
    && mkdir deps \
    && git add deps \
    && cmds/move-deps.sh \
    && rm deps/*/.git.bak \
    && rm .gitmodules.bak
