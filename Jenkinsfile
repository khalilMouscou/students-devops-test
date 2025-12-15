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

        stage('TESTS UNITAIRES & JaCoCo') {
            steps {
                sh "mvn clean test jacoco:report"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('VÉRIFICATION COUVERTURE') {
            steps {
                script {
                    sh '''
                        echo "🔍 Vérification de la couverture de code..."

                        # Check JaCoCo report exists
                        if [ -f "target/site/jacoco/jacoco.xml" ]; then
                            echo "✅ Rapport JaCoCo généré avec succès"

                            # Extract coverage percentage
                            COVERAGE=$(grep -o 'line-counter.*covered="[0-9]*"' target/site/jacoco/jacoco.xml | head -1 | grep -o '[0-9]*' | head -1)
                            if [ ! -z "$COVERAGE" ] && [ "$COVERAGE" -gt "0" ]; then
                                echo "✅ Couverture de code: $COVERAGE% (différente de 0)"
                            else
                                echo "⚠️ Couverture faible ou nulle"
                            fi
                        else
                            echo "❌ Échec: Rapport JaCoCo non généré"
                            exit 1
                        fi
                    '''
                }
            }
        }

        stage('ANALYSE SONARQUBE') {
            steps {
                script {
                    withSonarQubeEnv('SonarQube') {
                        sh """
                            echo "🔍 Lancement de l'analyse SonarQube..."

                            mvn sonar:sonar \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.projectName="${SONAR_PROJECT_NAME}" \
                                -Dsonar.java.binaries=target/classes \
                                -Dsonar.junit.reportsPath=target/surefire-reports \
                                -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml

                            echo "✅ Analyse SonarQube terminée"
                            echo "📊 Accédez au dashboard: http://localhost:9000/dashboard?id=${SONAR_PROJECT_KEY}"
                        """
                    }
                }
            }
        }

        stage('CONSTRUCTION LIVRABLE') {
            steps {
                sh "mvn package -DskipTests"
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
                    credentialsId: 'najdnagati',
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
    }

    post {
        success {
            echo "🎉 PIPELINE TERMINÉ AVEC SUCCÈS !"
            echo "===================================="
            echo "📦 Image Docker: ${DOCKER_IMAGE}:${DOCKER_TAG}"
            echo "🐋 DockerHub: https://hub.docker.com/r/najdnagati/student-management"
            echo "📊 SonarQube: http://localhost:9000/dashboard?id=${SONAR_PROJECT_KEY}"
            echo "📈 Rapport JaCoCo: target/site/jacoco/index.html"
            echo "🔗 Code Source: ${GIT_REPO}"
            echo "===================================="

            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            sh "mvn clean || true"
        }
        failure {
            echo "❌ ÉCHEC DU PIPELINE"
            echo "Consultez les logs pour détails"
            sh "mvn clean || true"
        }
        always {
            echo "🧹 Nettoyage des ressources..."
            sh "docker system prune -f || true"

            // Archive important reports
            archiveArtifacts artifacts: 'target/surefire-reports/*.xml, target/site/jacoco/*', fingerprint: true
        }
    }
}
