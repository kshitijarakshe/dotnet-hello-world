pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "kshitijadock/dotnet-hello-world:latest"
        DOCKERHUB_CREDENTIALS = credentials('dock-cred')
        EC2_HOST = "16.16.58.67"
        APP_DIR = "/home/ubuntu/dotnet-app"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                git url: 'https://github.com/kshitijarakshe/dotnet-hello-world.git', branch: 'master'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${DOCKER_IMAGE} .
                """
            }
        }

        stage('Docker Login & Push') {
            steps {
                sh """
                echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login -u "${DOCKERHUB_CREDENTIALS_USR}" --password-stdin
                docker push ${DOCKER_IMAGE}
                """
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@16.16.58.67 '
                        mkdir -p ${APP_DIR}
                        docker pull ${DOCKER_IMAGE}
                        docker stop dotnet-app || true
                        docker rm dotnet-app || true
                        docker run -d --name dotnet-app -p 80:80 ${DOCKER_IMAGE}
                    '
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                sh """
                sleep 10
                curl -f http://${EC2_HOST}:80/ || echo 'Health check failed'
                """
            }
        }
    }

    post {
        success {
            echo 'Application deployed successfully!'
        }
        failure {
            echo 'Build or deployment failed!'
        }
    }
}
