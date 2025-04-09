pipeline {
    agent any

    environment{
        DOCKER_IMAGE = 'lalbudha47/static-web-dashboard'
        CONTAINER_NAME = 'static-web-dashboard-container'
    }
    
    stages {

        // Repository Scann

        stage ('Repository Scan - Trivy') {
            steps{
                withCredentials([string(credentialsId: 'sudo-password', variable: 'SUDO_PASS')]) {
                echo 'Trivy Repository Scanning'
                sh 'trivy repo https://github.com/codeboylal/static-website-dashboard.git'
            }
        }

        stage ('Fetch Code - GitHub') {
            steps{
            echo 'Cloning Code From Github'
            git url:'https://github.com/codeboylal/static-website-dashboard.git', branch: 'main'
            
            // Manually passing the sudo password
            sh 'echo "your_sudo_password" | sudo -S cp -r * /var/www/html/'
            }
        }

        stage ('Building Code - Docker') {
            steps{
                echo 'Building Code to Docker'
                sh 'docker build -t static-web-dashboard .'       
            }
        }

        stage ('Image Scanning - Trivy') {
            steps{
                echo 'Scanning Build Image With Trivy'
               //  sh 'trivy image lalbudha47/static-web-dashboard'
               //  sh 'trivy image static-web-dashboard --format=json --output=trivy_image_scan_report.json'
                sh 'trivy image static-web-dashboard --format=table --output=trivy_image_scan_report_table.txt'
            }
        }

     // Trivy Generated report upload to AWS S3      
        stage('Upload Report - S3') {
            steps {
                echo 'Uploading trivy scanned report to AWS S3'
                s3Upload consoleLogLevel: 'INFO',
                        dontSetBuildResultOnFailure: false,
                        dontWaitForConcurrentBuildCompletion: false,
                        entries: [[bucket: 'jenkins-trivy',
                                    excludedFile: '',
                                    flatten: false,
                                    gzipFiles: false,
                                    keepForever: false,
                                    managedArtifacts: false,
                                    noUploadOnFailure: false,
                                    selectedRegion: 'us-east-1',
                                    showDirectlyInBrowser: false,
                                    sourceFile: 'trivy_image_scan_report_table.txt',
                                    storageClass: 'STANDARD',
                                    uploadFromSlave: false,
                                    useServerSideEncryption: false]],
                        pluginFailureResultConstraint: 'FAILURE',
                        profileName: 'Jenkins-s3-trivy-upload',
                        userMetadata: []
            }
        }

        stage ('Push Image - DockerHub') {
            steps {
                echo 'Pushing image to dockerhub'
                withCredentials([usernamePassword(credentialsId: 'static-web-connection', usernameVariable: 'dockerhubUser', passwordVariable: 'dockerhubPass')]) {
                    sh "docker tag static-web-dashboard $dockerhubUser/static-web-dashboard:latest"
                    sh "docker login -u $dockerhubUser -p $dockerhubPass"
                    sh "docker push $dockerhubUser/static-web-dashboard:latest"
                }
            }
        }

        // Deploy to Docker Container

        stage('Deploy - Docker') {
            steps {
                echo 'Deploying to container'
                sh "docker pull ${DOCKER_IMAGE}"
                
                echo 'Stopping previous container'
                sh "docker stop ${CONTAINER_NAME} || true"
                
                echo 'Removing previous container'
                sh "docker rm ${CONTAINER_NAME} || true"
                
                echo 'Starting new container'
                sh "docker run -d --name ${CONTAINER_NAME} -p 80:80 ${DOCKER_IMAGE}"
            }
        }
        
        // // Deploy to Kuberneter Cluster

        // stage('Deploy to K8S Cluster') {
        //     steps {
        //         script{
        //             kubernetesDeploy configs: 'static-website-deployment.yaml', kubeconfigId: 'Minikube'
        //         }
        //     }
        // }

    }
}