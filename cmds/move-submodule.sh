#!/bin/sh -ex

here=`cd "\`dirname \"$0\"\`";pwd`

cd $here

from=$1
to=$2

function run ()
{
    "$@"
}

function ran ()
{
    echo "$@"
}

if test $# -ne 2; then
    echo "Usage: $(basename $0) <from> <to>"
    exit 1
fi

if test -z "$WINDIR"; then
    case `uname` in
        Darwin*|darwin*)
            SED_I="-i .bak"
            ;;

        Linux*|linux*)
            SED_I="-i"
            ;;
    esac
else
    # Windows
    SED_I="-i"
fi

run sed $SED_I                                   \
    -e "s!url = \\(.*\\)/$from\$!url = \\1/$to!" \
    -e "s!path = $from\$!path = $to!"            \
    .gitmodules

to_parent_dir="$(dirname $to)"

to_name="$(basename $to)"
from_name="$(basename $from)"

if test -f $from/.git; then
    run sed $SED_I                                             \
        -e "s!worktree = \\(.*\\)/$from\$!worktree = \\1/$to!" \
        ".git/modules/$from_name/config"

    backpath="$(echo $to | sed -e 's![^/]*!..!g')"
    cp $from/.git $from/.git.bak
    echo "gitdir: $backpath/.git/modules/$from_name" > $from/.git
fi

run mkdir -p $to_parent_dir

run mv -v $from $to

run git add $to

run git rm --cached $from

git submodule sync $to

git add .gitmodules

cat .gitmodules | grep "$to\$"

cd -
