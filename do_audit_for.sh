#!/bin/bash

export AUDIT_USER=${1}

echo \$0: $0

# parse SSH_ORIGINAL_COMMAND to figure out what the user wanted to do
read tool session user <<< "$SSH_ORIGINAL_COMMAND"

echo tool: $tool
echo session: $session
echo user: $user
export AUDIT_TOOL=$tool
export AUDIT_SESSION=$session
export AUDIT_UID=$user

export PATH="~/bin:$PATH"
env
if [[ $AUDIT_TOOL == "audit" ]] ; then
  setup_audit_work
  perform_audit
  clean_audit_work
fi
echo "THIS IS MY SPECIAL LOGIN SHELL. HANGING UP."

#####
# EOF
