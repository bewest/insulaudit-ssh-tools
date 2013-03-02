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

export SESS_KEY="${user}-${session}"
export BRANCH="audit/$(date +%F)-${SESS_KEY}"
export WORK_BASE="$HOME/sessions/${SESS_KEY}"
export WORK_CONF=$WORK_BASE/conf
export WORK_REMOTE=$WORK_BASE/remote.git
export WORK_LOCAL=$WORK_BASE/local
export VMODEM=${WORK_BASE}/vmodem

export PATH="$HOME/bin:$PATH"
export WORK_BASE WORK_CONF WORK_REMOTE WORK_LOCAL BASE VMODEM

SESSION_CONFIG=$WORK_CONF/audit.config
export SESSION_CONFIG BRANCH SESS_KEY

. common

if [[ $AUDIT_TOOL == "audit" ]] ; then
  PHR_REPO=$(read_config registration.phr)
  export PHR_REPO
  env
  setup_audit_work
  echo "CREATE VMODEM" $(which create_vmodem)
  create_vmodem $WORK_CONF/audit.config
  sleep 2
  perform_audit
  clean_audit_work
else
  env
  echo "HOWDY, $user"
  echo "DID NOT UNDERSTAND:" $AUDIT_TOOL
  echo "YOUR COMMAND:"
  ssh-add -l
  echo $SSH_ORIGINAL_COMMAND

fi
ps
echo "THIS IS MY SPECIAL LOGIN SHELL. HANGING UP."

#####
# EOF
