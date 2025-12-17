pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "kshitijadock/dotnet-hello-world:latest"
        DOCKERHUB_CREDENTIALS = credentials('dock-cred')
        EC2_HOST = '16.16.58.67' // replace with your EC2 IP
        EC2_KEY = credentials('ec2-ssh-key')  // SSH private key stored in Jenkins
        APP_DIR = "/home/ubuntu/dotnet-app"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                git url: 'https://github.com/kshitijarakshe/dotnet-hello-world.git', branch: 'main'
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
                sh """
                ssh -i ${EC2_KEY} -o StrictHostKeyChecking=no ${EC2_HOST} '
                    mkdir -p ${APP_DIR} &&
                    docker pull ${DOCKER_IMAGE} &&
                    docker stop dotnet-app || true &&
                    docker rm dotnet-app || true &&
                    docker run -d --name dotnet-app -p 80:80 ${DOCKER_IMAGE}
                '
                """
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
        failure {
            echo 'Build or deployment failed!'
        }
        success {
            echo 'Application deployed successfully!'
        }
    }
}
