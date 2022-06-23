pipeline {

    agent {
    label 'eng110-jenkins-worker'
    }

    parameters {
      booleanParam defaultValue: true, description: 'Carry out terraform destroy?', name: 'Destroy'
    }

    stages {
        stage('Checkout') {
            steps {
                 script{
                        dir("terraform")
                        {
                            checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/samuel-walters/Complete-CICD']]])
                        }
                    }
                }
            }

        stage('Plan') {
            steps {
                script{
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'my-aws-credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        dir("terraform") {
                            sh 'terraform init -input=false'
                            sh "terraform plan -input=false -out tfplan "
                            sh 'terraform show -no-color tfplan > tfplan.txt'
                        }
                    }
                }
            }  
        }
        

        stage('Apply') {
            steps {
                script {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'my-aws-credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        dir("terraform") {
                            sh "terraform apply -input=false tfplan"
                        }
                    }
                }
            }
        }
        
        stage('Destroy') {
            steps {
                script {
                    if(params.Destroy == true){  
                        withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'my-aws-credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            dir("terraform") {
                            sh "terraform destroy --auto-approve"
                            }
                        }
                    } else {
                        echo "Skipping terraform destroy"
                    }
                } 
            }
        }
    }
}