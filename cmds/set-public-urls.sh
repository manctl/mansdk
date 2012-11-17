#!/bin/sh

here=`cd "\`dirname \"$0\"\`";pwd` ; source "$here/cmd.sh" ; cd "$here/.."

sed_i                                                               \
    -e 's!git@github.com:manctl/!git://github.com/manctl/!'         \
    -e 's!git@bitbucket.org:manctl/!https://bitbucket.org/manctl/!' \
    .gitmodules

git submodule sync
