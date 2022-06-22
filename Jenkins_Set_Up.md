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
> 12. To allow the jenkins user in the agent node to run sudo commands, type the commands `sudo su` and then `nano /etc/sudoers`. Add this line (or edit if it already exists): `jenkins ALL= NOPASSWD: ALL`. 

# Configuration Details in the Browser

> 1. Go to Jenkins in the browser (master-node-public-ip:8080). For Initial Administrator password, run (in your master node) the command `sudo cat /var/lib/jenkins/secrets/initialAdminPassword` and paste it into the box.
> 2. Allow yourself to pick custom plugins. Make sure `SSH agent`, `GitHub`, and `SSH` are selected (and pick whatever plugins you desire - there will also be time to install plugins later with the Plugin Manager).
> 3. After you have installed the plugins, choose details for your Admin User and click `save and continue`. 

# Configure a Cloud

> 1. In the Jenkins `Plugin Manager`, search for `Amazon EC2 plugin` and install it without restarting.
> 2. Go to `Configure Clouds` and select `Amazon EC2`.
> 3. For `Amazon EC2 Name`, put a name like `my-ec2`.
> 4. Add your EC2 Credentials. For `Kind`, remember to select `AWS Credentials`.
> 5. Click apply and save.

# Create an agent node

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

# Set up AWS CLI

> 1. Create a job, and run these commands on your worker node in the `Execute shell` part to install AWS CLI:
```
sudo apt-get update
sudo apt-get install awscli -y
aws --version
```
> 2. Create a pipeline, and your script should look like this: 
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
> 3. This script relies upon the `Amazon EC2 plugin`. View the [Configure a Cloud](https://github.com/samuel-walters/Complete-CICD/blob/main/Jenkins_Set_Up.md#Configure-a-Cloud) section to see how to set this up.

# Set up Terraform

> 1. Click on `Manage Jenkins` in the browser.
> 2. Click `Manage Plugins`, and go to the available tab.
> 3. Search for terraform, and click `Install without restart`.
> 4. Click `Manage Jenkins`, then click `Global Tool Configuration` from the `System configuration section`.
> 5. Scroll down to the `Terraform` section and click `Add Terraform`.
> 6. Enter a Name of your choice. I’m going to use “eng110-terraform”.
> 7. **Untick** the box that says `Install automatically`. By default, this box gets ticked. 
> 8. For `Install directory`, enter `/usr/bin` and click `Apply` and then `Save`.
> 9. Once again, click `Manage Jenkins`. Go to `Manage Credentials`.
> 10. Click on `Jenkins`. Click on `Global credentials (unrestricted)`, and click `Add Credentials`.
> 11. Under `Kind`, click the drop-down and select `Secret text`. 
> 12. For secret, copy and paste your AWS Access Key.
> 13. For `ID`, type `AWS_ACCESS_KEY_ID` and click `OK`.
> 14. Repeat the process for your secret access key, and make sure for `ID` you put `AWS_SECRET_ACCESS_KEY`.
> 15. Go back to the Dashboard, and click on `New Item`.
> 16. After entering a new name, click on `Pipeline`.
> 17. Tick the box that says `This Pipeline is parameterised`. 
> 17. In the pipeline section, select `Pipeline script from SCM`. 
> 18. Choose `Git`.
> 19. Enter your repository where your Jenkinsfile is located.
> 20. Choose your primary branch. Check if `master` should be changed to `main`.
> 21. The `Script Path` should be `Jenkinsfile`.
> 22. Double check your details look similar to the image below (but with a different GitHub repository):
![](https://i.imgur.com/gdtDuKe.png)
> 23. Select `Build with Parameters`, and choose `terraform`. Click `build`.

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