# Install Jenkins on Master Node

> 1. Make sure your security group allows port 8080.
> 2. Run sudo apt-get update -y
> 3. Visit https://pkg.jenkins.io/debian-stable/, and run the commands on there.
> 4. Run `sudo systemctl start jenkins`.

# Worker Node(s) Set Up

> 1. Security group for workers: just allow port 22 for SSH.
> 2. Run `sudo apt-get update -y`.
> 3. Run `sudo apt-get install fontconfig openjdk-11-jre`. 
> 4. Run `sudo useradd -m jenkins`.
> 5. Run `sudo -u jenkins mkdir /home/jenkins/.ssh`.
> 6. In your **MASTER NODE**, type in `ssh-keygen`. Copy the public key (in the ~/.ssh directory).
> 7. In your **SLAVE NODE**, run `sudo -u jenkins nano /home/jenkins/.ssh/authorized_keys`. 
> 8. Paste in the public key. Save and exit. 
> 9. In your **MASTER NODE**, test the ssh connection with `ssh jenkins@ip-iphere` (take the ip from the **SLAVE NODE'**'s terminal).
> 10. Exit by pressing ctrl + D, or entering in the word `exit`.
> 11. In your **MASTER NODE**, type in the command `sudo cp ~/.ssh/known_hosts /var/lib/jenkins/.ssh`.

# Configuration Details in the Browser

> 1. On Jenkins in the browser (ip:8080), click on `Manage Jenkins` and then `Manage nodes and clouds`.
> 2. Initial Administrator password: in your master node, run the command `sudo cat /var/lib/jenkins/secrets/initialAdminPassword` and paste it into the box.
> 3. Allow yourself to pick custom plugins. Make sure `ssh agent` and `GitHub` are selected (and pick whatever plugins you desire - there will also be time to install plugins later with the Plugin Manager).
> 4. After you have installed the plugins, choose details for your Admin User and click `save and continue`. 
> 5. Click on `New Node`.
> 6. Name it the same as your EC2 worker instance (for example `eng110-jenkins-worker`).
> 7. Click `Permanent Agent`, and click `Create`. 
> 8. For `number of executors`, put `1`. 
> 9. For `Remote root directory`, put in `/home/jenkins`.
> 10. For `Labels`, put in the same Name (for example `eng110-jenkins-worker`).
> 11. For `Usage`, put `Only build jobs with label expressions matching this node`.
> 12. For `Launch method`, choose `Launch agents via SSH`. 
> 13. For `Host`, put in the worker node's IP found in the terminal. For example (ubuntu@ip-**ipyouwanthere** -- only select the highlighted part). Remember to replace the dashes with dots.
> 14. For `Credentials`, click `add` and choose `Jenkins`.
> 15. Choose `SSH username with private key`. 
> 16. Username should be `jenkins` (all lower-case).
> 17. Click enter directly, and copy and paste the private key from your **MASTER NODE** (that looks like `id_rsa` and is located inside the ~/.ssh folder). 
> 18. In the description, put `my jenkins private key`.
> 19. Click `Add`.
> 20. Select your key (should be able to see the description in this selection too). 
> 21. For `Host Key Verification Strategy`, choose `Manually trusted key Verification Strategy`. 
> 22. Click save, and run a build to test if it is working.