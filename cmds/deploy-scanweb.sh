#!/bin/sh

STAGE=stage/relwithdebinfo/bin
CHECKER=skanweb-license-checker
GENERATOR=skanweb-license-generator

cd $STAGE

rsync -e "ssh -p 2280" -LvzP $CHECKER \
    skanect@manctl.com:skanweb/license-checker/

rsync -e "ssh -p 2280" -LvzP $GENERATOR \
    skanect@manctl.com:skanweb/license-generator/

if false; then
    for f in `ldd $CHECKER | cut -f 2 -d '>' | cut -f 1 -d '('`; do 
	rsync -e "ssh -p 2280" -LvzP $f \
	    skanect@manctl.com:skanweb/lib/
    done
fi
