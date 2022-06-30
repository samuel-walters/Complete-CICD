> 1. To access private instances, first use these commands to get the private key file used to access the instances into your memory:
```
eval `ssh-agent -s`.
ssh-add eng119.pem
```
> 2. Now you must connect to the public instance with the NAT gateway with a command that looks like this: `ssh -A ubuntu@34.248.82.44`.
> 3. In the public instance, type the command `ssh ubuntu@10.0.2.241`, replacing the ip address with the instance's private ip address.

