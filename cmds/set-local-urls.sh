#!/bin/sh

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

sed $SED_I \
-e 's!git@github.com:manctl/!/Users/nt/Work/manctl/mansdk/!' \
-e 's!git@bitbucket.org:manctl/!/Users/nt/Work/manctl/mansdk/!' \
.gitmodules
 
cat .gitmodules

#git submodule sync
#git submodule update
