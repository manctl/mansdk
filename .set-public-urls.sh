#!/bin/sh

if test -z "$WINDIR"; then
    case `uname` in
        Darwin*|darwin*)
            SED_I="-i ''"
            ;;

        Linux*|linux*)
            SED_I="-i"
            ;;
    esac
else
    # Windows
    SED_I="-i"
fi

sed $SED_I \
-e 's!git@github.com:manctl/!git://github.com/manctl/!' \
-e 's!git@bitbucket.org:manctl/!https://bitbucket.org/manctl/!' \
.gitmodules

git submodule sync
git submodule update
