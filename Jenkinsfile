pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['UAT', 'PROD'], description: 'Select deployment environment')
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag')
    }

    environment {
        // Docker Hub
        DOCKER_IMAGE_NAME = 'kshitijadock/dotnet-hello-world'
        DOCKERHUB_CREDS = credentials('dock-cred')

        // AWS / EC2 SSH key (global)
        EC2_SSH_KEY = credentials('ec2-ssh-key')

        // Application
        CONTAINER_NAME = 'dotnet-app'
        APP_PORT = '80'
    }

    stages {

        stage('Set Environment Variables') {
            steps {
                script {
                    if (params.ENVIRONMENT == 'UAT') {
                        env.EC2_HOST = '13.48.84.147'        // UAT EC2 IP
                        env.APP_DIR = '/home/ubuntu/dotnet-uat'
                    } else if (params.ENVIRONMENT == 'PROD') {
                        env.EC2_HOST = '13.48.84.147'      // PROD EC2 IP
                        env.APP_DIR = '/home/ubuntu/dotnet-prod'
                    }

                    env.FULL_IMAGE = "${DOCKER_IMAGE_NAME}:${params.IMAGE_TAG}"
                }
            }
        }

        stage('Checkout Source Code') {
            steps {
                git branch: 'master', url: 'https://github.com/kshitijarakshe/dotnet-hello-world.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${FULL_IMAGE} .
                '''
            }
        }

        stage('Docker Login & Push Image') {
            steps {
                sh '''
                echo "$DOCKERHUB_CREDS_PSW" | docker login -u "$DOCKERHUB_CREDS_USR" --password-stdin
                docker push ${FULL_IMAGE}
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh '''
                ssh -i $EC2_SSH_KEY -o StrictHostKeyChecking=no ubuntu@${EC2_HOST} << EOF
                    mkdir -p ${APP_DIR}
                    docker pull ${FULL_IMAGE}
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p ${APP_PORT}:80 \
                        ${FULL_IMAGE}
                EOF
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                sleep 10
                curl -f http://${EC2_HOST}:${APP_PORT}/ || exit 1
                '''
            }
        }
    }

    post {
        success {
            echo "Deployment to ${params.ENVIRONMENT} successful"
        }
        failure {
            echo "Deployment to ${params.ENVIRONMENT} failed"
        }
        always {
            sh 'docker logout || true'
        }
    }
}
