#!/bin/bash

key=${1}

echo \$0: $0
echo key: $key
echo args: $*
echo args: $@
echo ENV
env
echo "THIS IS MY SPECIAL LOGIN SHELL. HANGING UP."

#####
# EOF
