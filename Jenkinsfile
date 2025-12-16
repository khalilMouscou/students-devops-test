pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'khalilmouscou/students-devops-test'
        DOCKER_TAG = "1.0.0"
        GIT_REPO = 'https://github.com/khalilMouscou/students-devops-test.git'
        GIT_BRANCH = "main"
    }

    tools {
        maven 'M2_HOME'
        jdk '$JAVA_HOME'
    }

    stages {

        stage('RÉCUPÉRATION CODE') {
            steps {
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO}"
            }
        }

        stage('CONSTRUCTION LIVRABLE (Skip Tests)') {
            steps {
                sh "mvn clean package -DskipTests"
            }
        }

        stage('BUILD DOCKER IMAGE') {
            steps {
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                        echo "✅ Image Docker construite: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    """
                }
            }
        }

        stage('PUSH DOCKERHUB') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'mouscou24',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                        docker logout || true
                        echo "✅ Images poussées sur DockerHub"
                    """
                }
            }
        }

        stage('RUN DOCKER CONTAINER') {
            steps {
                sh """
                    docker stop student-management || true
                    docker rm student-management || true
                    docker run -d --name student-management -p 8080:8080 ${DOCKER_IMAGE}:${DOCKER_TAG}
                    echo "✅ Container lancé sur le port 8080"
                """
            }
        }
    }

    post {
        success {
            echo "🎉 PIPELINE TERMINÉ AVEC SUCCÈS !"
            echo "📦 Image Docker: ${DOCKER_IMAGE}:${DOCKER_TAG}"
            echo "🐋 DockerHub: https://hub.docker.com/r/najdnagati/student-management"
            echo "🔗 Code Source: ${GIT_REPO}"
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            sh "mvn clean || true"
        }
        failure {
            echo "❌ ÉCHEC DU PIPELINE"
            echo "Consultez les logs pour détails"
            sh "mvn clean || true"
        }
        always {
            echo "🧹 Nettoyage des ressources Docker..."
            sh "docker system prune -f || true"
        }
    }
}
