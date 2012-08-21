#!/bin/sh

if test -z "$WINDIR"; then
    case `uname` in
        Darwin)
            SED_I="-i ''"
            ;;

        linux)
            SED_I="-i"
            ;;
    esac
else
    # Windows
    SED_I="-i"
fi

sed $SED_I \
-e 's!git://github.com/manctl/!git@github.com:manctl/!' \
-e 's!https://bitbucket.org/manctl/!git@bitbucket.org:manctl/!' \
.gitmodules
 
git submodule sync
git submodule update
