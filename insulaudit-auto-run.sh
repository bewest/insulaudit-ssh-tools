#!/bin/bash

print_sms | while read sms ; do
  rm new.config
  fetch_config_from $sms | validate_config new.config
  if [[ -f new.config ]] ; then
    mv new.config good.config
    auditor=$(setup_session good.config) # tell management to give us a port now!
    forward_stick.sh $auditor # perform auditing
    # may not need this? or use proxy command instead:
    # ssh -C good.config audit.me # ha!
  fi
done