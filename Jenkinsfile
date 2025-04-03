pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/codeboylal/static-website-dashboard.git'
        BRANCH_NAME = 'devops'
        CREDENTIALS_ID = 'devops-morning-git-token'
    }
    
    stages {
        
        stage('Code Fetch') {
            steps {
                echo 'Fetching code from GitHub'
                checkout([$class: 'GitSCM', 
                    branches: [[name: "*/${BRANCH_NAME}"]], 
                    userRemoteConfigs: [[url: REPO_URL, credentialsId: CREDENTIALS_ID]]
                ])
            }
        }

        stage ('Building Code - Docker') {
            steps{
                echo 'Building Code to Docker'
                sh 'docker build -t my-static-image .'       
            }
        }


        // Deployment Stage
        stage ('Running Code - Docker') {
            steps{
                echo 'Running Code to Docker'
                sh '''
                docker ps -q | xargs -r docker stop
                docker ps -aq | xargs -r docker rm
                '''
                sh 'docker run -d -p 3030:80 my-static-image'
            }
        }
    }
}