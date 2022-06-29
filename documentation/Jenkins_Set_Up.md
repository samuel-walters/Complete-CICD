# Install Jenkins on Master Node

> 1. Choose Ubuntu 18.04 on AWS. 
> 2. Make sure your security group allows port 8080.
> 3. Run sudo apt-get update -y
> 4. Visit https://pkg.jenkins.io/debian-stable/, and run the commands on there. The commands are pasted below just in case:
```bash 
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install fontconfig openjdk-11-jre
sudo apt-get install jenkins
```
> 5. Run `sudo systemctl start jenkins`.

# Worker Node(s) Set Up

> 1. Choose Ubuntu 18.04 on AWS.
> 2. Security group for workers: just allow port 22 for SSH.
> 3. Run `sudo apt-get update -y`.
> 4. Run `sudo apt-get install fontconfig openjdk-11-jre`. 
> 5. Run `sudo useradd -m jenkins`.
> 6. Run `sudo -u jenkins mkdir /home/jenkins/.ssh`.
> 7. In your **MASTER NODE**, type in `ssh-keygen`. Copy the public key (in the ~/.ssh directory).
> 8. In your **SLAVE NODE**, run `sudo -u jenkins nano /home/jenkins/.ssh/authorized_keys`. 
> 9. Paste in the public key. Save and exit. 
> 10. In your **MASTER NODE**, test the ssh connection with `ssh jenkins@ip-iphere` (take the ip from the **SLAVE NODE'**'s terminal).
> 11. Exit by pressing ctrl + D, or entering in the word `exit`.
> 12. In your **MASTER NODE**, type in the command `sudo cp ~/.ssh/known_hosts /var/lib/jenkins/.ssh`.
> 13. To allow the jenkins user in the agent node to run sudo commands, type the commands `sudo su` and then `nano /etc/sudoers`. Add this line (or edit if it already exists): `jenkins ALL= NOPASSWD: ALL`. 

# Configuration Details in the Browser

> 1. Go to Jenkins in the browser (master-node-public-ip:8080). For Initial Administrator password, run (in your master node) the command `sudo cat /var/lib/jenkins/secrets/initialAdminPassword` and paste it into the box.
> 2. Allow yourself to pick custom plugins. Make sure `SSH agent`, `GitHub`, and `SSH` are selected (and pick whatever plugins you desire - there will also be time to install plugins later with the Plugin Manager).
> 3. After you have installed the plugins, choose details for your Admin User and click `save and continue`. 

# Configure a Cloud

> 1. In the Jenkins `Plugin Manager`, search for `Amazon EC2` and install it without restarting.
> 2. Go to `Configure Clouds` and select `Amazon EC2`.
> 3. For `Amazon EC2 Name`, put a name like `my-ec2`.
> 4. Add your EC2 Credentials. For `Kind`, remember to select `AWS Credentials`.
> 5. Click apply and save.

# Connect an Agent Node

> 1. Click on `Manage Jenkins` and then `Manage nodes and clouds`.
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
> 15. In the description, put `my jenkins private key`.
> 16. Click `Add`.
> 17. Select your key (should be able to see the description in this selection too). 
> 18. For `Host Key Verification Strategy`, choose `Manually trusted key Verification Strategy`. 
> 19. Click save, and run a build to test if it is working.

## Use a Webhook to Connect Jenkins with a GitHub Repository 

> 1. Create a new key in your .ssh folder on your localhost with `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`.
> 2. Run this command on the public (.pub) key generated to copy its contents: `clip < ~/.ssh/eng110_cicd_sam.pub`.
> 3. Go to `Settings` in the GitHub repository you want to connect with Jenkins.
> 4. Go to `Deploy Keys`.
> 5. Add a key, and copy the contents from the `clip` command into the box. 
> 6. On Jenkins in your browser, create a new freestyle build.
> 7. Remember naming conventions.
> 8. Tick Discard old builds. Max # of builds to keep = 3.
> 9. GitHub project - use the http link **NOT** ssh.
> 10. Tick restrict where this project can be run.
> 11. For Label Expression, type in the name of your worker node. In this case, I will enter `eng110-jenkins-worker` (you might need to press backspace and fiddle around with it until it recognises the label).
> 12. For Source Code Management, choose `Git`.
> 13. For `Repository URL`, choose the repository's **SSH** link. 
> 14. Run this command on the private key generated to copy its contents: `clip < ~/.ssh/eng110_cicd_sam`.
> 15. Credientials: add a new key.
> 16. Choose SSH Keys. Give it the same name as your private key (for example eng110_cicd_sam).
> 17. Paste the private key's contents into the box.
> 18. Make sure it is */main and not */master (GitHub used to use master but that has since changed).
> 19. Under `Build Triggers`, click `GitHub hook trigger for GITScm polling.
> 20. Add some simple commands in `Execute shell`, for example `pwd`. 
> 21. Save the Jenkins Job. 
> 22. Go to the GitHub repository linked to your Jenkins job, and click `settings.`
> 23. Go to your `Webhooks`.
> 24. Click `Add webhook`.
> 25. Use the Jenkins IP, and add `github-webhook` at the end. For example, it may look like this:
                http://ipaddress:port/github-webhook/
> 26. Click `Let me select individual events`, and select `push` and `pull`.
> 27. Click `Add webhook`.
> 28. Test your webhook by pushing a commit to your GitHub repository. This should automatically trigger the Jenkins job to run, and you will be able to look at the output and see whether the agent node ran the commands you put into the `Execute shell` section. 

# Set up AWS CLI

> 1. Create a job, and run these commands on your worker node in the `Execute shell` part to install AWS CLI:
```
sudo apt-get update
sudo apt-get install awscli -y
aws --version
```
> 2. Create a declarative pipeline, and your script should look like this: 
``` Groovy
pipeline {
    agent { label 'mynode' }
    environment {
        AWS_DEFAULT_REGION="eu-west-1"
    }
    stages {
        stage('Hello') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'my-credentials-aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) { 
                    sh '''
                        aws --version
                        aws ec2 describe-instances
                    '''
                }
            }
        }
    }
}
```
> 3. This script relies upon the `Amazon EC2 plugin`. View the [Configure a Cloud](https://github.com/samuel-walters/Complete-CICD/blob/main/documentation/Jenkins_Set_Up.md#Configure-a-Cloud) section to see how to set this up.

# Set Up Docker

> 1. SSH into your agent node, and run these commands to install Docker:
```bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install docker.io -y
```
> 2. On your Jenkins browser, go to `Manage Jenkins` and then `Plugin Manager`. Install `Docker Pipeline` (without restart).

# Set Up Terraform

## Installing Terraform

> 1. Create a new job called `install terraform`, and tick `Restrict where this project can be run`. Select the name of your worker node, and under `Build` select `Execute shell`. Copy and paste this script to install terraform:
```bash
wget https://releases.hashicorp.com/terraform/1.0.3/terraform_1.0.3_linux_amd64.zip
sudo apt-get install unzip
unzip terraform_1.0.3_linux_amd64.zip             
sudo mv terraform /usr/bin
terraform -v
```
> 2. Click on `Manage Jenkins` in the browser.
> 3. Click `Manage Plugins`, and go to the available tab.
> 4. Search for terraform, and click `Install without restart`.
> 5. Click `Manage Jenkins`, then click `Global Tool Configuration` from the `System configuration section`.
> 6. Scroll down to the `Terraform` section and click `Add Terraform`.
> 7. Enter a Name of your choice. I’m going to use “eng110-terraform”.
> 8. **Untick** the box that says `Install automatically`. By default, this box gets ticked. 
> 9. For `Install directory`, enter `/usr/bin` and click `Apply` and then `Save`.

## Creating a pipeline

> 1. Go to the Dashboard, and click on `New Item`.
> 2. After entering a new name, click on `Pipeline`.
> 3. In the pipeline section, select `Pipeline script from SCM`. 
> 4. Choose `Git`.
> 5. Enter the repository where your Jenkinsfile and main.tf files are located.
> 6. Choose your primary branch. Check if `master` should be changed to `main`.
> 7. For `Script Path`, enter the relative path for your `Jenkinsfile` that contains the code to run your terraform commands. Your screen should look something like this (but with a different GitHub repository and relative path):
![](https://i.imgur.com/l7gbDsE.png)
> 8. The Jenkins pipeline will require AWS credentials. View the [Configure a Cloud](https://github.com/samuel-walters/Complete-CICD/blob/main/documentation/Jenkins_Set_Up.md#Configure-a-Cloud) section to see how to set this up.

## Setting up Environment Variables in Jenkins for Terraform

> 1. Go to `Manage Jenkins`, and then `Configure System`.
> 2. Scroll down to `Global Properties`, and tick `Environment Variables`.
> 3. The name of the variable **must** begin with `TF_VAR_`. For example, a variable could be called `TF_VAR_vpc_cidr`. 
> 4. Enter the value for your variable. Your screen should look something like this:
![](https://i.imgur.com/lRdMUPy.png)
> 5. Click `Apply` and then `Save`.
> 6. In your `main.tf` file, ensure you have a variable block. For the above example, the block would look like this:
```terraform
variable "vpc_cidr"{
}
```
> 7. In `main.tf`, you will now be able to refer to the variable by using the syntax `var.name_of_variable`. For example, in this case, you would type `var.vpc_cidr`.

# Set Up Ansible

## Installing Ansible

> 1. In your agent node, become the `jenkins` user with the command `sudo su jenkins`.

> 2. Run these commands. These versions have been selected because they are compatible with one another:

```bash
sudo apt update -y
sudo apt upgrade -y
sudo apt install python
sudo apt install python-pip -y
sudo apt install python3-pip
alias python=python3
sudo python3 -m pip install botocore==1.26.0
sudo python3 -m pip install awscli==1.24.0 botocore==1.26.0
pip3 install boto boto3==1.23.0 botocore==1.26.0
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible -y
```
> 3. Run the following commands:

```bash
cd /etc/ansible
sudo mkdir group_vars
cd group_vars
sudo mkdir all
cd all
```
> 4. Run the command `sudo ansible-vault create pass.yml`, and enter a password (twice) of your choosing.
> 5. You will enter Vim (a text editor) which can be tricky to use.
> 6. To insert information, hold shift and press i. 
> 7. Enter your AWS credentials using this format:

```bash
ec2_access_key: keyhere
ec2_secret_key: keyhere
```
> 8. To save and exit vim, press esc, and then type :wq! and press enter.
> 9. Run the command `sudo chmod 666 pass.yml`.
> 10. To test ansible vault, try typing `sudo cat pass.yml`. Make sure you cannot see your keys in the output.
> 11. Go to your `.ssh` directory with `cd ~/.ssh`.
> 12. Make sure the directory has the private key needed to SSH into the instances you wish to provision. 
> 13. The `.ssh` directory will also require the public key. To get the public key, you can run this command: `ssh-keygen -y -f ~/.ssh/file_name.pem > ~/.ssh/file_name.pub`.
> 14. Run the command `sudo chmod 400 eng119.pem`.
> 15. Return to `/etc/ansible`. Type `sudo nano hosts`.
> 16. Enter lines similar to these, specifying all the instances you want ansible to connect with and provision (remember to change relevant details such as the path to the key)
```
[local]
localhost ansible_python_interpreter=/usr/local/bin/python3

[controlplane]
control ansible_host=ec2-176-34-157-191.eu-west-1.compute.amazonaws.com ansible_user=ubuntu ansible_ssh_private_key_file=/home/jenkins/.ssh/eng119.pem

[workers]
worker ansible_host=ec2-54-195-172-104.eu-west-1.compute.amazonaws.com ansible_user=ubuntu ansible_ssh_private_key_file=/home/jenkins/.ssh/eng119.pem
worker1 ansible_host=ec2-34-245-138-168.eu-west-1.compute.amazonaws.com ansible_user=ubuntu ansible_ssh_private_key_file=/home/jenkins/.ssh/eng119.pem
```
> 17. To test it is working, create a yaml file (which will be used as an Ansible playbook) with the command `sudo touch test.yml`.
> 18. For now, enter simple instructions such as the ones below:
```yaml
---
- hosts: controlplane

  gather_facts: yes
```
> 19. Check if the playbook works with `sudo ansible-playbook test.yml --ask-vault-pass`.
> 20. Google error messages if they do appear. Usually these messages reveal what went wrong quite clearly, such as an incorrect path to your private key or the key not having the right permissions (which should be granted with `sudo chmod 400 key.pem`).

## Automating Set Up of Ansible Hosts File

> 1. Your agent will need AWS CLI installed. View step one of the "[Set up AWS CLI](https://github.com/samuel-walters/Complete-CICD/blob/main/documentation/Jenkins_Set_Up.md#Set-up-AWS-CLI)" section to see how to install AWS CLI.
> 2. This automated process will also require AWS credentials. View the [Configure a Cloud](https://github.com/samuel-walters/Complete-CICD/blob/main/documentation/Jenkins_Set_Up.md#Configure-a-Cloud) section to see how to add these credentials to Jenkins.
> 3. Click on the `Dashboard` in the Jenkins browser, and select `Freestyle project` with a name of your choice (for example `set-up-ansible-hosts`).
> 4. Tick `Discard old builds`, and for `Max # of builds to keep` enter 3.
> 5. Tick `Restrict where this project can be run`, and enter your agent node's name (which in this case is `eng110-jenkins-worker`). Wait for it to say this under the box: `Label eng110-jenkins-worker matches 1 node`. You may need to hit backspace if it does not show up initially.
> 6. Under `Build Environment`, tick `Use secret text(s) or file(s)`, and select your AWS Credentials.
> 7. Also select `SSH Agent`, and choose your private key needed to access your agent instance.
> 8. For `build`, choose `Execute shell`.
> 9. The syntax for the `Execute shell` box will look like this:
```bash
PublicDNSName1=$(aws ec2 describe-instances \
--filters Name=tag:Name,Values="eng110-project-kubernetes-controlplane" \
--query Reservations[*].Instances[*].PublicDnsName \
--region eu-west-1 \
--output text)

PublicDNSName2=$(aws ec2 describe-instances \
--filters Name=tag:Name,Values="eng110-project-kubernetes-worker1" \
--query Reservations[*].Instances[*].PublicDnsName \
--region eu-west-1 \
--output text)

PublicDNSName3=$(aws ec2 describe-instances \
--filters Name=tag:Name,Values="eng110-project-kubernetes-worker2" \
--query Reservations[*].Instances[*].PublicDnsName \
--region eu-west-1 \
--output text)

sudo rm /etc/ansible/hosts
sudo tee -a /etc/ansible/hosts > /dev/null <<EOT
[local]
localhost ansible_python_interpreter=/usr/local/bin/python3

[controlplane]
control ansible_host=${PublicDNSName1} ansible_user=ubuntu ansible_ssh_private_key_file=/home/jenkins/.ssh/eng119.pem

[workers]
worker ansible_host=${PublicDNSName2} ansible_user=ubuntu ansible_ssh_private_key_file=/home/jenkins/.ssh/eng119.pem
worker1 ansible_host=${PublicDNSName3} ansible_user=ubuntu ansible_ssh_private_key_file=/home/jenkins/.ssh/eng119.pem
EOT
```
> 10. Remember to replace the names of these instances. In this case, names such as `eng110-project-kubernetes-worker1` are determined by a terraform script (found at the bottom of [main.tf](https://github.com/samuel-walters/Complete-CICD/blob/main/terraform_files/main.tf) in this repository).

## Running Ansible from Jenkins Pipeline

> 1. In your agent node, navigate to /etc/ansible, and type `sudo nano ansible.cfg`.
> 2. Add these lines to the file - it will ensure that no prompt will appear when you try to connect to instances for the first time:
```
[defaults]
host_key_checking = False
```
> 3. Click on `Manage Jenkins` in the browser, and go to `Manage Credentials`. 
> 4. Click on `Jenkins` (global), and then click `Global credentials (unrestricted)`.
> 5. Click `Add Credentials` on the left, and for `Kind` choose `Secret File`.
> 6. You will need to upload a simple .txt file which contains the password used to access Ansible Vault.
> 7. Go to the `Dashboard`, and click `New Item`. Enter a name like `Run Ansible`, and choose `Pipeline` and hit `OK`.
> 8. In the `Pipeline` section, choose the `SCM` option.
> 9. For `SCM`, choose `Git`.
> 10. Enter your GitHub Repository's URL (the same URL you used to clone the repository).
> 11. Check whether branch should be `main` instead of `master`.
> 12. For `Script Path`, provide the path to your Jenkinsfile.
> 13. Your pipeline should look like something resembling the image below. Remember to  replace details such as the repository link and the relative path to the Jenkinsfile:
![](https://i.imgur.com/sAoLAru.png)

# Creating Users and Setting up Permissions

> 1. In your browser, click `Manage Jenkins` and then `Manage users`. Click `Create User` on the left-hand side.
> 2. Click on `Manage Jenkins` again, and navigate to `Manage Plugins`. From here click on `Available`.
> 3. Search for `roles` and tick `Role-based Authorization Strategy`. 
> 4. Click `Install without restart`. 
> 5. Go to `Manage Jenkins` and then `Configure Global Security`. Tick the box that says `Role-Based Strategy`. Hit apply and then save.
> 6. On `Manage Jenkins`, navigate to `Manage and Assign Roles`. Go to `Manage Roles`, and then add a role and tick the boxes you want the role to have permission for. The below image demonstrates an example of this:

![](https://i.imgur.com/KmFrA6Y.png)
> 7. From `Manage and Assign Roles`, go to `Assign Roles`. Add the user you created and tick the appropriate role. This is an example of what your table might look like:

![](https://i.imgur.com/N1LP4EB.png)