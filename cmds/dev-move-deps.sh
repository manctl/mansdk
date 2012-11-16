#!/bin/sh -ex

true \
    && git reset --hard \
    && rm -rf deps \
    && git submodule init \
    && git submodule update \
    && mkdir deps \
    && git add deps \
    && ./.move-deps.sh \
    && rm deps/*/.git.bak \
    && rm .gitmodules.bak
