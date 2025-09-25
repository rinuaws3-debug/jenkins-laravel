pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "yourdockerhub/laravel-app" // your DockerHub repo
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                     url: 'https://github.com/youruser/laravel-app.git',
                     credentialsId: 'github-cred'
            }
        }

        stage('Composer Install') {
            steps {
                sh 'composer install --no-dev --optimize-autoloader'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .'
            }
        }

        stage('Docker Push') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-cred', url: '']) {
                    sh 'docker push $DOCKER_IMAGE:$BUILD_NUMBER'
                    sh 'docker tag $DOCKER_IMAGE:$BUILD_NUMBER $DOCKER_IMAGE:latest'
                    sh 'docker push $DOCKER_IMAGE:latest'
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                  docker rm -f laravelapp || true
                  docker run -d -p 8086:80 --name laravelapp $DOCKER_IMAGE:$BUILD_NUMBER
                '''
            }
        }
    }
}

