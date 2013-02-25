# ssh + git hacks

## Quick intro
This method automatically forwards serial device over ssh for one-time consumption.
After resource is consumed once, all ports and sessions are closed cleanly.

Here's example output with actual data:
https://github.com/bewest/insulaudit-ssh-tools/blob/master/example.log

https://github.com/bewest/insulaudit-ssh-tools/blob/master/socat_forward_stick.sh - from beaglebone/remote socat and ssh end
Uses a reverse port forward in order to get control sequence right, this is reverse of what we've been thinking, but somewhat trivial/technical difference.

https://github.com/bewest/insulaudit-ssh-tools/blob/master/create_vmodem - server side socat
https://github.com/bewest/insulaudit-ssh-tools/blob/master/do_audit_for.sh - server side authorize port+shell+resource
https://github.com/bewest/insulaudit-ssh-tools/blob/master/perform_audit - auditing script

https://github.com/bewest/diabetes/blob/audit/2013-02-25-6-403332564/incoming.log
Here's the resulting checked-in log file.

The resource can only be consumed once using this implementation; the whole pipeline is shut-down after a single open/close session on the virtual modem.

## Details
See:
### `authorized_keys`
* [ssh `authorized_keys`](http://man.he.net/man5/authorized_keys)

Gitolite and svnserve use this technique to map an authenticated key
to a specified user by setting up the entire shell so that it's
customized for the user.

See: http://sitaramc.github.com/gitolite/auth.html
```
Now, if you managed to read about gitolite and ssh, you know that
gitolite is meant to be invoked as:

/full/path/to/gitolite-shell some-authenticated-gitolite-username
(where the "gitolite username" is a "virtual" username; it does not
have to be, and usually isn't, an actual unix username).
```

Part of "user setup" or registration has to be adding an entry for the user's
beagle bone key to our `authorized_keys_` file

For example,
This entry prevents `bash` or `sh` from running.  Usually what happens
is ssh will start bash as the new user.

EG a normal session:
```bash
bewest@paragon:~/src$ ssh insulaudit@bewest.io 'whoami ; env ; echo
$SHELL'
insulaudit
MAIL=/var/mail/insulaudit
USER=insulaudit
SSH_CLIENT=24.5.43.241 53043 22
HOME=/home/insulaudit
LOGNAME=insulaudit
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
LANG=en_US.UTF-8
SHELL=/bin/sh
PWD=/home/insulaudit
SSH_CONNECTION=24.5.43.241 53043 10.170.185.103 22
/bin/sh
bewest@paragon:~/src$ 
```

### With the `authorized_keys`:
```
command="FOO=BAR /home/insulaudit/bin/do_audit_for.sh bewest" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSZh82PI+uQe62fNvmqNNdB6mpPjJfpoPlxt515PVKjUpE49YQUXpdkbOYNHGtT5cRWdvEBJ7zVyJt0Iiy2cUVZjO2dgd/+iKwTNbFXvk9WyKP/MRwij3AHrf+nMMg9csz0qQ5JwRqBktjOuf3Vxkrf/bkUROxnvj1CU3SDNe7NUx7aGF/awwnQ19vzS/T6oCUct+ivGNWX+ZBLVLeWzPxm4T88Lw6v/ASWeHRydVtEoAOj66F1EP1R429EwBnasZi1a6sqeh3H8wNtqysaN4ultrOPsQldENKOTApZbjtAEL5u03m+/gRxu0PGymDhUFSn08ruwB8qxAedwfS4D9P bewest@ip-10-170-185-103

command="FOO=BAR /home/insulaudit/bin/do_audit_for.sh bewest" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIvYgpg7C+4qqpGAelfX9BilYe4Qs6pJlOlLyZU553w+dmCBb3JGfcMoT8ppBse3N/MTY+DhZ6pfSq//h81wQdj1ieSn6TshCzUyt/crbp+5VPUobj8Y/3DiByiNgnGmY6L17qab3OMCK7ns/+WGWkfGYmN2XFxqbVpENTE2AYyOMkl++VFi+B5UTuqR3XLhlVj1xY0928tEpxKKZIfJaKgcIfxkgVM9fQnH3z/kFM1AIER4oB933CROlln9CXKTFOODUvWk8Xqh2R88DxjcCbaNUrBrsMDvqfb5z3mFKWPhaNgi8Y4gsNiDCgZpsoZJV/uXQRGtdTvfNWHgtCoXcD bewest@paragon

```

```bash
bewest@ip-10-170-185-103:~/src/insulaudit$ ssh insulaudit 'whoami ; env ; echo $SHELL'
$0: /home/insulaudit/bin/do_audit_for.sh
key: bewest
args: bewest
args: bewest
ENV
SHELL=/bin/sh
FOO=BAR
SSH_CLIENT=184.169.177.192 46828 22
USER=insulaudit
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
MAIL=/var/mail/insulaudit
PWD=/home/insulaudit
LANG=en_US.UTF-8
SHLVL=1
HOME=/home/insulaudit
SSH_ORIGINAL_COMMAND=whoami ; env ; echo $SHELL
LOGNAME=insulaudit
SSH_CONNECTION=184.169.177.192 46828 10.170.185.103 22
_=/usr/bin/env
THIS IS MY SPECIAL LOGIN SHELL. HANGING UP.
bewest@ip-10-170-185-103:~/src/insulaudit$
```

So we are able to take initialize a specified shell session with our
authenticated user.  All we need to do now is authorise some ports for
auditing.

Here's stack overflow on the subject:
* [restricting access to git](http://superuser.com/questions/299927/can-you-specify-git-shell-in-ssh-authorized-keys-to-restrict-access-to-only-git)
* [how gitolite uses ssh](http://sitaramc.github.com/gitolite/glssh.html)

```
restricting shell access/distinguishing one user from another

The answer to the first question is the command= we talked about
before. If you look in the authorized_keys file, you'll see entries
like this (I chopped off the ends of course; they're pretty long
lines):

  command="[path]/gitolite-shell sitaram",[more options] ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA18S2t...
  command="[path]/gitolite-shell usertwo",[more options] ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArXtCT...
First, it finds out which of the public keys in this file match the
incoming login. That's crypto stuff, and I won't go into it. Once the
match has been found, it will run the command given on that line;
e.g., if I logged in, it would run [path]/gitolite-shell sitaram. So
the first thing to note is that such users do not get "shell access",
which is good!

Before running the command, however, sshd sets up an environment
variable called SSH_ORIGINAL_COMMAND which contains the actual git
command that your workstation sent out. This is the command that would
have run if you did not have the command= part in the authorised keys
file.

When gitolite-shell gets control, it looks at the first argument
("sitaram", "usertwo", etc) to determine who you are. It then looks at
the SSH_ORIGINAL_COMMAND variable to find out which repository you
want to access, and whether you're reading or writing.

Now that it has a user, repository, and access requested (read/write),
gitolite looks at its config file, and either allows or rejects the
request.

But this cannot differentiate between different branches within a
repo; that has to be done separately.
```

## Updating authorized keys
https://github.com/sitaramc/gitolite/blob/master/src/triggers/post-compile/ssh-authkeys
Looks like @sitaramc tries very hard to keep duplicate entries out,
and to keep the "curated" list separate from any manually added
entries.

## gitolite

You can emulate
[gitolite-shell](https://github.com/sitaramc/gitolite/blob/master/src/gitolite-shell)
manually by doing something like like this
`SSH_ORIGINAL_COMMAND="$action" gitolite-shell bewest`
This actually runs as user git, but gitolite knows to set up all
following commands as the "bewest" user.  It looks in it's config
files for all needed information at this point, although it can
interact with some out of band service as well.

Action here is something like "upload, recieve, etc...." 


## git hacks
This one is interesting:
https://github.com/progrium/gitreceive/blob/master/gitreceive

## How to check in medical records using beaglebone

* https://github.com/bewest/decoding-carelink
* https://github.com/n-west/insulware
* https://github.com/bewest/insulaudit
* https://github.com/n-west/meta-insulaudit

Take a stab at the overall workflow for what happens when the beaglebone "goes live".

Theory of operation is that given some message with a server, we want to exchange keys and generate a new valid config.
Then we use the config to start up an auditing session.  An auditing session consists of connecting the local hardware with a remote server process that can perform the device-specific auditing.

These steps are a suggestion on how to generate a "valid config" given an SMS, and how to trigger the server-side process.

### Config

Assume this config:

```
[deviceDetect]
vid=1111
pid=2222

[resourceRequest]
addr=bewest.io
port=80
audit=medevice://YmV3@bewest.io:9001/insulauditpage=audit.php
userid=bew
key_loc=12739022

[serialToNet]
addr=bewest.io
port=9001

[registration]
addr=bewest.io
pollinginterval=300
phr=git@github.com:bewest/diabetes-phr.git
firstname=Ben
lastname=West
```

So now that do_audit_for knows to set up a user, it needs to set up a
new work area.
```bash
BASE=/home/insulaudit/
USER=bewest
KEY=12739022 # some unique key
WORK=$BASE/$USER-$KEY
mkdir -p $WORK
PHR_REMOTE=git@github.com:bewest/diabetes.git
git clone $PHR_REMOTE $WORK
cd $WORK
BRANCH="audit-$KEY"
git checkout -b $BRANCH
```


Given a port forward, we can set up a vmodem

```bash
USER=$USER
DEVICE=$BASE/devices/$USER-$KEY.ttyUSB
PORT=9001
socat pty,link=$DEVICE,b9600,raw TCP-L:$PORT
```

Then run insulaudit to audit some records from a medical device.
```bash
VID=1111
PID=2222
guess=$(insulaudit guess --vid $VID --pid $PID)
tool=${guess-"mini.py"}
OUTPUT=$WORK/insulaudit-$(date +%F).log
$tool $DEVICE > $OUTPUT
```

Then wrap it up, and send the phr back from whence it came.
```bash
cd $WORK
summarize_audit $OUTPUT > summary.log
make_manifest $USER $SESSION . > manifest.phr
git add .
git commit -F summary.log
git push origin $BRANCH
```

Hmm, kill socat, clean up work??
```bash
cd
# we hope this kills socat on both remote and local side
rm $DEVICE
rm -Rf $WORK
```



This ssh config allows ssh command like:
`ssh insulaudit`
```config
Host insulaudit

  Compression no
  User insulaudit
  Hostname bewest.io
  IdentityFile /home/bewest/.ssh/insulaudit.key
  # LocalForward 4142 localhost:4142  # eg $port

```
We use something like this from the beaglebone to connect to the
server.  The idea is that socat has forwarded a pty to a TCP
interface, and that ssh stitches the port onto a remote host where
relevant services can make the best use of the connected device.
