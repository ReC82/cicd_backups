pipeline {
    agent {
        label "main"
    }

    environment {
        // SERVER CONFIG
        SONARQUBE = "10.1.5.4"
        GRAFANA = "10.10.1.4"
        JENKINS = "10.10.1.1"

        // SERVER CREDENTIALS
        SONARQUBE_CREDS_ID = "QualityControl"
        GRAFANA_CREDS_ID = "Nagios"

        // BACKUP SCRIPTS CONFIG
        SONAR_SCRIPT="/opt/sonarqube/backup/sonarqube_backup.sh"
        GRAFANA_SCRIPT="/var/lib/grafana/backup/backup_grafana_db.sh"
        JENKINS_SCRIPT="/var/lib/jenkins/backup/jenkins_backup_script.sh"

        // REMOTE BACKUP FILE
        SONAR_BACKUP_FILE="/opt/sonarqube/backup/*.sql"

        // BACKUP FOLDER
        SONAR_BKP_FOLDER="./backups/sonarqube"
        GRAFANA_BKP_FOLDER="./backups/grafana"
        JENKINS_BKP_FOLDER="./backups/jenkins"

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

        // SONARQUBE BACKUP
        stage('Backup SonarQube') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(
                        credentialsId: env.SONARQUBE_CREDS_ID,
                        keyFileVariable: 'SSH_KEY_FILE',
                        usernameVariable: 'SSH_USER'
                    )]) {
                        sh """
                            ssh-keyscan \${SONARQUBE} >> ~/.ssh/known_hosts

                            ssh -i \${SSH_KEY_FILE} -o StrictHostKeyChecking=no \${SSH_USER}@\${SONARQUBE} \\
                                "cd /tmp && sudo -u sonar bash \${SONAR_SCRIPT}"

                            scp -i \${SSH_KEY_FILE} -o StrictHostKeyChecking=no \${SSH_USER}@\${SONARQUBE}:\${SONAR_BACKUP_FILE} \${SONAR_BKP_FOLDER}
                        """
                    }
                }
            }
        }

        stage('Commit Backup') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(
                        credentialsId: env.GIT_CREDENTIALS,
                        keyFileVariable: 'GIT_KEY_FILE'
                    )]) {
                        sh """
                            git add .
                            git commit -m "Backup SonarQube"
                            git push -u origin \${TARGET_BRANCH}
                        """
                    }
                }
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