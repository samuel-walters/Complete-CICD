pipeline {
    agent {
    label 'eng110-jenkins-worker'
    }

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy Terraform build?')
    }

    stages {
        stage('checkout') {
            steps {
                 script{
                        dir("terraform")
                        {
                            checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/samuel-walters/Complete-CICD']]])
                            sh 'echo $(pwd)'
                            sh 'echo $(ls)'
                        }
                    }
                }
            }

        stage('Plan') {
            steps {
                script{
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'my-aws-credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("terraform")
                        {
                                sh 'echo HELLOOOOO'
                                sh 'echo $(ls)'
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
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'my-aws-credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("terraform") {
                           sh "terraform destroy --auto-approve"
                    }
                    }
            }
        }
    }

  }
}