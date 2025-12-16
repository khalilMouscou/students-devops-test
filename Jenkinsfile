pipeline {
    agent any

    environment {
        GIT_REPO     = 'https://github.com/khalilMouscou/students-devops-test.git'
        GIT_BRANCH  = 'main'
        DOCKER_IMAGE = 'khalilmouscou/students-devops-test'
        DOCKER_TAG   = '1.0.0'
        CONTAINER_NAME = 'student-management'
    }

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_17'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: GIT_BRANCH, url: GIT_REPO
            }
        }

        stage('Build Maven (Skip Tests)') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'mouscou24',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      --restart unless-stopped \
                      -p 8080:8080 \
                      ${DOCKER_IMAGE}:${DOCKER_TAG}
                '''
            }
        }
    }

    post {
        success {
            echo '🎉 PIPELINE TERMINÉE AVEC SUCCÈS'
            echo "📦 Image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
            echo '🌍 Application: http://localhost:8080'
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }

        failure {
            echo '❌ ÉCHEC DE LA PIPELINE'
        }

        always {
            echo '🧹 Nettoyage images Docker inutilisées'
            sh 'docker image prune -f || true'
        }
    }
}
