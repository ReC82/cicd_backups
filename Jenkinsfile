pipeline {
    agent {
        label "main"
    }

    environment {
        // SERVER CONFIG
        SONARQUBE = "10.1.5.4"
        GRAFANA = "10.10.1.4"
        JENKINS = "10.10.1.1"

        // EMAIL CONFIG
        RECIPIENTS = 'lody.devops@gmail.com'
        SENDER_EMAIL = 'jenkins@lodywood.be'

        // GIT CONFIG
        ARTIFACT_REPO = 'git@github.com:ReC82/cicd_backups.git'
        GIT_CREDENTIALS = 'GitJenkins'
        TARGET_BRANCH = 'main'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }       
    }
    post {
        failure {
            emailext(
                subject: "Backup Job failed: ${currentBuild.fullDisplayName} - ${currentBuild.result}",
                body: """
Build Result: ${currentBuild.result}
Build Number: ${currentBuild.number}
Build URL: ${env.BUILD_URL}
You can download the build report [here](${env.BUILD_URL}artifact/build-report.txt).
""",
                to: env.RECIPIENTS,
                from: env.SENDER_EMAIL,
                attachLog: true
            )
        }
    }
}
