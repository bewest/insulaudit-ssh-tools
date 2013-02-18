#!/bin/bash

print_sms | while read sms ; do
  rm new.config
  fetch_config_from $sms | validate_config new.config
  if [[ -f new.config ]] ; then
    mv new.config good.config
    auditor=$(setup_session good.config)  # tell management to give us a port now!
    # auditor == "./ssh-audit-4142-D34DB33F.config
    ssh -F $auditor auditor run_stick $auditor
    # remote side has a login shell that only responds to "run_stick" and a few other commands, or run_stick is a command that takes the session "key"
  fi
done