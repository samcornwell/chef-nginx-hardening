
peline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh 'echo hi'
            }
        }
    }
    post {
        always {
            junit 'build/reports/**/*.xml'
        }
    }
}}    
