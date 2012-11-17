#!/bin/sh

here=`cd "\`dirname \"$0\"\`";pwd` ; source "$here/cmd.sh" ; cd "$here/.."

sed_i                                                               \
    -e 's!git://github.com/manctl/!git@github.com:manctl/!'         \
    -e 's!https://bitbucket.org/manctl/!git@bitbucket.org:manctl/!' \
    .gitmodules
 
git submodule sync
