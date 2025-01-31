pipeline {
    agent {
        label "main"
    }

    environment {
        // SERVER CONFIG
        SONARQUBE = "10.1.5.4"
        GRAFANA = "10.1.6.4"
        JENKINS = "10.10.1.1"

        // SERVER CREDENTIALS
        SONARQUBE_CREDS_ID = "quality.pem"
        GRAFANA_CREDS_ID = "monitoring.pem"

        // BACKUP SCRIPTS CONFIG
        SONAR_SCRIPT="/opt/sonarqube/backup/sonarqube_backup.sh"
        GRAFANA_SCRIPT="/var/lib/grafana/backup/backup_grafana_db.sh"
        JENKINS_SCRIPT="/var/lib/jenkins/backup/jenkins_backup_script.sh"

        // REMOTE BACKUP FILE
        SONAR_BACKUP_FILE="/opt/sonarqube/backup/*.sql"
        GRAFANA_BACKUP_FILE="/var/lib/grafana/backup/*.db"

        // BACKUP FOLDER
        SONAR_BKP_FOLDER="./backups/sonarqube"
        GRAFANA_BKP_FOLDER="./backups/grafana"
        JENKINS_BKP_FOLDER="./backups/jenkins"

        // EMAIL CONFIG
        RECIPIENTS = 'lody.devops@gmail.com'
        SENDER_EMAIL = 'jenkins@lodywood.be'

        // GIT CONFIG
        ARTIFACT_REPO = 'git@github.com:ReC82/cicd_backups.git'
        GIT_CREDENTIALS = 'GitJekinsToken'
        TARGET_BRANCH = 'main'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage("Clone Git Repository") {
            steps {
                git(
                    url: "https://github.com/ReC82/cicd_backups.git",
                    branch: "main",
                    changelog: true,
                    poll: true
                )
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

        // GRAFANA BACKUP
        stage('Backup Grafana') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(
                        credentialsId: env.GRAFANA_CREDS_ID,
                        keyFileVariable: 'SSH_KEY_FILE',
                        usernameVariable: 'SSH_USER'
                    )]) {
                        sh """
                            ssh-keyscan \${GRAFANA} >> ~/.ssh/known_hosts

                            ssh -i \${SSH_KEY_FILE} -o StrictHostKeyChecking=no \${SSH_USER}@\${GRAFANA} \\
                                "cd /tmp && sudo -u grafana bash \${GRAFANA_SCRIPT}"

                            scp -i \${SSH_KEY_FILE} -o StrictHostKeyChecking=no \${SSH_USER}@\${GRAFANA}:\${GRAFANA_BACKUP_FILE} \${GRAFANA_BKP_FOLDER}
                        """
                    }
                }
            }
        }        

        stage('Commit Backup') {
            steps {
                withCredentials([gitUsernamePassword(
                    credentialsId: env.GIT_CREDENTIALS
                )]) {
                    sh """
                        cd \${WORKSPACE}
                        git add .
                        git commit -m "Backup changes"
                        git push -u origin \${TARGET_BRANCH}
                    """
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