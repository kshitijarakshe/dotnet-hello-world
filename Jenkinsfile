pipeline {
    agent any

    environment {
        DOCKER_CREDS = credentials('dock-cred') // Replace with your Jenkins DockerHub credential ID
        IMAGE_NAME = "kshitijadock/dotnet-hello-world:latest"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/kshitijarakshe/dotnet-hello-world.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(IMAGE_NAME)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dock-cred') {
                        docker.image(IMAGE_NAME).push()
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@51.20.134.44 '
                        docker pull ${IMAGE_NAME} &&
                        docker stop dotnet-app || true &&
                        docker rm dotnet-app || true &&
                        docker run -d --name dotnet-app -p 5000:5000 ${IMAGE_NAME}
                        '
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                sh 'curl -f http://<EC2_PUBLIC_IP>:5000/ || exit 1'
            }
        }
    }

    post {
        failure {
            mail to: 'kshitijarakshe.com',
                 subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Check Jenkins console output at ${env.BUILD_URL}"
        }
    }
}
