#!/bin/sh -e

here=`cd "\`dirname \"$0\"\`";pwd` ; source "$here/cmd.sh" ; cd "$here/.."

echo "This half-assed script worked once during a migration."
echo "Use at your own risk."

if test $# -ne 2; then
    echo "Usage: $(basename $0) <from> <to>"
    exit 1
fi

from=$1
to=$2

to_parent_dir="$(dirname $to)"
to_name="$(basename $to)"
from_name="$(basename $from)"

sed_i                                            \
    -e "s!url = \\(.*\\)/$from\$!url = \\1/$to!" \
    -e "s!path = $from\$!path = $to!"            \
    .gitmodules

if test -f $from/.git; then
    sed_i                                                      \
        -e "s!worktree = \\(.*\\)/$from\$!worktree = \\1/$to!" \
        ".git/modules/$from_name/config"

    backpath="$(echo $to | sed -e 's![^/]*!..!g')"
    cp $from/.git $from/.git.bak
    echo "gitdir: $backpath/.git/modules/$from_name" > $from/.git
fi

mkdir -p $to_parent_dir

mv -v $from $to

git add $to

git rm --cached $from

git submodule sync $to

git add .gitmodules

cat .gitmodules | grep "$to\$"
