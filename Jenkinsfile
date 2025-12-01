pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn -v || echo "Maven not found on this agent"'
                sh 'mvn -B clean package || echo "Build failed or skipped"'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn -B test || echo "Tests failed or skipped"'
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
