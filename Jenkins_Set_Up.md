# Install Jenkins (On Master Node)

> 1. Make sure your security group allows port 8080.
> 2. Run sudo apt-get update -y
> 3. Visit https://pkg.jenkins.io/debian-stable/, and run the commands on there.
> 4. Run `sudo systemctl start jenkins`.

# Worker Node(s) Set Up

> 1. Security group for workers: just allow port 22 for SSH.
> 2. Run `sudo apt-get update-y`.
> 3. Run `sudo apt-get install fontconfig openjdk-11-jre`. 
> 4. Run `sudo useradd -m jenkins`.
> 5. Run `sudo -u jenkins mkdir /home/jenkins/.ssh`.
> 6. In your **MASTER NODE**, type in ssh-keygen. Copy the public key.
> 7. In your **SLAVE NODE**, run `sudo -u jenkins nano /home/jenkins/.ssh/authorized_keys`. 
> 8. Paste in the public key.
> 9. In your **MASTER NODE**, test the ssh connection with `ssh jenkins@ip-iphere` (take the ip from the **SLAVE NODE'S** terminal).
> 10. Exit by pressing ctrl + D, or entering in the word `exit`.
> 11. In your **MASTER NODE**, type in the command `sudo cp ~/.ssh/known_hosts /var/lib/jenkins/.ssh`.

# Set Up Worker Node

> 1. On Jenkins in the browser (ip:8080), click on `Manage Jenkins` and then `Manage nodes and clouds`.
> 2. Click on `New Node`.
> 3. Name it the same as your EC2 worker instance (for example `eng110-jenkins-worker`).
> 4. Click `Permanent Agent`, and click `Create`. 
> 5. For `number of executors`, put `1`. 
> 6. For `Remote root directory`, put in `/home/jenkins`.
> 7. For `Labels`, put in the same Name (for example `eng110-jenkins-worker`).
> 8. For `Usage`, put `Only build jobs with label expressions matching this node`.
> 9. For `Launch method`, choose `Launch agents via SSH`. 
> 10. For `Host`, put in the worker node's IP found in the terminal. For example (ubuntu@ip-**ipyouwanthere** -- only select the highlighted part). Remember to replace the dashes with dots.
> 11. For `Credentials`, click `add` and choose `Jenkins`.
> 12. Choose `SSH username with private key`. 
> 13. Username should be `jenkins` (all lower-case).
> 14. Click enter directly, and copy and paste the private key from your **MASTER NODE** (that looks like `id_rsa` and is located inside the ~/.ssh folder). 
> 15. In the description, say `my jenkins private key`.
> 16. Click `Add`.
> 17. Select your key (should be able to see the description in this selection too). 
> 18. For `Host Key Verification Strategy`, choose `Manually trusted key Verification Strategy`. 
> 19. Click save, and run a build to test it is working.