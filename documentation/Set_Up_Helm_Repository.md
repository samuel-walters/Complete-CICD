# Set Up a Helm Repository on GitHub

### Prerequisites 
Before following the steps below, make sure you have Helm installed by typing the command `helm version` in your terminal. If it is not installed, navigate to Helm's official [installation page](https://helm.sh/docs/intro/install/) and follow the steps for your operating system.

### Instructions

> 1. Create a new repository on GitHub. Name it anything you want.
> 2. Clone the repository - for example, with `git clone git@github.com:samuel-walters/eng110-helm.git`. 
> 3. Create the directory charts with `mkdir charts`. Then inside charts (cd charts), create another directory where you will store all the yaml files. For example, you could try typing (inside charts) `mkdir eng110-nodeapp`.
> 4. Create a new chart with `helm create eng110-nodeapp` (replace with the desired directory).
> 5. Run `helm lint eng110-nodeapp` to test if the chart is well-formed.
> 6. Exit the charts directory with `cd ..`, and run `helm package charts/*` to create the Helm chart package.
> 7. Get the index.yaml file with `helm repo index --url https://your-github-username.github.io/your-github-repository/ .`.
> 8. Commit and push these changes to GitHub.
> 9. In your repository on GitHub, go to `Settings` and then `Pages`. Configure it as follows:
![](https://i.imgur.com/zbLI9te.png)
> 10. Wait until the `Pages` section says `Your site is published at url-here` at the top in green. 
> 11. You can now add the repository with `helm repo add my-custom-local-repo-name https://samuel-walters.github.io/eng110-helm/` (use the link you see in the `Pages` section of the GitHub repository's settings).
> 12. Run the command `helm repo update`.
> 13. Run the command `helm search repo` to see your newly added local repository.
> 14. Run the command `helm install custom-name your-previous-custom-local-repo-name/name-of-directory`. The image below details how this command should be used to install the repository found in the middle of the output for `helm search repo`:
![](https://i.imgur.com/trRNAWz.png)