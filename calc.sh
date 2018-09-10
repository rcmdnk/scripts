#!/usr/bin/env bash

# Calculate with perl (for decimal, etc...)

eq=${*//^/**}
printf "\$xx =%s;print \"\$xx \\n\"" "$eq"|perl
