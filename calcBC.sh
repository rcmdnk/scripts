#!/usr/bin/env bash
eq="$*"
eq=$(echo "$eq"|sed "s/e+\([0-9]*\)/*10^\1/g")
eq=$(echo "$eq"|sed "s/e\([0-9]*\)/*10^\1/g")
eq=$(echo "$eq"|sed "s/e\(-[0-9]*\)/*10^\1/g")
eq=$(echo "$eq"|sed "s/E+\([0-9]*\)/*10^\1/g")
eq=$(echo "$eq"|sed "s/E\([0-9]*\)/*10^\1/g")
eq=$(echo "$eq"|sed "s/E\(-[0-9]*\)/*10^\1/g")
eq=$(echo "$eq"|sed "s/\*\*/^/g")
echo "$eq"|bc -l
