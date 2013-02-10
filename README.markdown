## How to check in medical records using beaglebone

* https://github.com/bewest/decoding-carelink
* https://github.com/n-west/insulware
* https://github.com/bewest/insulaudit
* https://github.com/n-west/meta-insulaudit

Take a stab at the overall workflow for what happens when the beaglebone "goes live".

Theory of operation is that given some message with a server, we want to exchange keys and generate a new valid config.
Then we use the config to start up an auditing session.  An auditing session consists of connecting the local hardware with a remote server process that can perform the device-specific auditing.

These steps are a suggestion on how to generate a "valid config" given an SMS, and how to trigger the server-side process.