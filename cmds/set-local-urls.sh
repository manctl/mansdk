#!/bin/sh -e

here=`cd "\`dirname \"$0\"\`";pwd` ; source "$here/cmd.sh" ; cd "$here/.."

if test $# -ne 1; then
    echo "Usage: $(basename $0) <path>"
    exit 1
fi

path=$1

sed_i                                       \
    -e "s!git@github.com:manctl/!$path!"    \
    -e "s!git@bitbucket.org:manctl/!$path!" \
    .gitmodules
 
git submodule sync
