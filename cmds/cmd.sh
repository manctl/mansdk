#!/bin/sh

# Usage:
# here=`cd "\`dirname \"$0\"\`";pwd` ; source "$here/cmd.sh" ; cd "$here/.."

function run ()
{
    "$@"
}

function ran ()
{
    echo "$@"
}

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

function sed_i ()
{
    sed $SED_I "$@"
}
