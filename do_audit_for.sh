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
export VMODEM=${WORK_BASE}/vmodem

export PATH="$HOME/bin:$PATH"
export WORK_BASE WORK_CONF WORK_REMOTE WORK_LOCAL BASE VMODEM
env
if [[ $AUDIT_TOOL == "audit" ]] ; then
  . setup_audit_work
  echo "CREATE VMODEM" $(which create_vmodem)
  create_vmodem $WORK_CONF/audit.config
  sleep 2
  . perform_audit
  . clean_audit_work
fi
ps
echo "THIS IS MY SPECIAL LOGIN SHELL. HANGING UP."

#echo $PPID
#kill -9 $PPID


#####
# EOF
