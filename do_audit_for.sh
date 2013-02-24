#!/bin/bash

export AUDIT_USER=${1}

echo \$0: $0

COMMANDS=${SSH_ORIGINAL_COMMAND-'audit 403332564 6'}

# parse SSH_ORIGINAL_COMMAND to figure out what the user wanted to do
read tool session user <<< "$COMMANDS"

echo tool: $tool
echo session: $session
echo user: $user
export AUDIT_TOOL=${tool}
export AUDIT_SESSION=${session}
export AUDIT_UID=${user}

export BASE=$HOME/session

export WORK_BASE="$HOME/sessions/${user}-${session}"
export WORK_CONF=$WORK_BASE/conf
export WORK_REMOTE=$WORK_BASE/remote
export WORK_LOCAL=$WORK_BASE/local

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
