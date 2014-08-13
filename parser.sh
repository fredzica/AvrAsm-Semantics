#!/bin/bash

dir=`dirname $0`

tmp=$(mktemp /tmp/AvrAsm-parsing.XXXXXXXX)
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT INT TERM

cat $1 > ${tmp}

python3 preprocessor.py ${tmp} `dirname $1` 

kast ${tmp}
