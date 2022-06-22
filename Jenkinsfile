pipeline {
    agent {
    label 'eng110-jenkins-worker'
    }

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy Terraform build?')
    }


     environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
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
                    dir("terraform")
                        {
                                sh 'echo $(ls)'
                                sh 'sudo terraform init -input=false'
                                sh "sudo terraform plan -input=false -out tfplan "
                                sh 'sudo terraform show -no-color tfplan > tfplan.txt'
                        }
                }
                }
            }
        
        stage('Approval') {
           steps {
               script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
           }
       }

        stage('Apply') {
            
            steps {
                sh "terraform apply -input=false tfplan"
            }
        }
        
        stage('Destroy') {
        
        steps {
           sh "terraform destroy --auto-approve"
        }
    }

  }
}