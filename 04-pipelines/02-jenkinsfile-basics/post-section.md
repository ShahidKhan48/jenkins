# Post Section

## 📋 What is the Post Section?

The post section defines actions to run at the end of pipeline execution or stage completion, regardless of the pipeline's status.

## 🎯 Post Conditions

### **always**
Runs regardless of pipeline status.
```groovy
post {
    always {
        echo 'This will always run'
        cleanWs()  // Clean workspace
    }
}
```

### **success**
Runs only if pipeline succeeds.
```groovy
post {
    success {
        echo 'Pipeline succeeded!'
        slackSend color: 'good', message: 'Build successful'
    }
}
```

### **failure**
Runs only if pipeline fails.
```groovy
post {
    failure {
        echo 'Pipeline failed!'
        emailext subject: 'Build Failed', body: 'Check Jenkins for details'
    }
}
```

### **unstable**
Runs only if pipeline is unstable (tests failed but build succeeded).
```groovy
post {
    unstable {
        echo 'Pipeline is unstable'
        slackSend color: 'warning', message: 'Build unstable - tests failed'
    }
}
```

### **changed**
Runs only if pipeline status changed from previous run.
```groovy
post {
    changed {
        echo 'Pipeline status changed'
        emailext subject: 'Build Status Changed', body: 'Status changed from previous build'
    }
}
```

### **fixed**
Runs only if pipeline was broken and is now fixed.
```groovy
post {
    fixed {
        echo 'Pipeline is now fixed!'
        slackSend color: 'good', message: 'Build is now fixed! 🎉'
    }
}
```

### **regression**
Runs only if pipeline was successful and is now failing/unstable.
```groovy
post {
    regression {
        echo 'Pipeline regressed'
        emailext subject: 'Build Regression', body: 'Build was working but now failing'
    }
}
```

### **aborted**
Runs only if pipeline was aborted.
```groovy
post {
    aborted {
        echo 'Pipeline was aborted'
        slackSend color: 'warning', message: 'Build was aborted'
    }
}
```

### **cleanup**
Runs after all other post conditions.
```groovy
post {
    cleanup {
        echo 'Final cleanup'
        deleteDir()  // Delete entire workspace
    }
}
```

## 🏗️ Pipeline-level Post

### **Complete Example**
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
    }
    post {
        always {
            echo 'Pipeline completed'
            // Archive artifacts
            archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
            // Publish test results
            publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
            // Clean workspace
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
            slackSend(
                color: 'good',
                message: "✅ Build #${BUILD_NUMBER} succeeded\n${BUILD_URL}"
            )
        }
        failure {
            echo 'Pipeline failed!'
            slackSend(
                color: 'danger',
                message: "❌ Build #${BUILD_NUMBER} failed\n${BUILD_URL}console"
            )
            emailext(
                subject: "Build Failed: ${JOB_NAME} - ${BUILD_NUMBER}",
                body: "Build failed. Check console output at ${BUILD_URL}console",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
        unstable {
            echo 'Pipeline is unstable'
            slackSend(
                color: 'warning',
                message: "⚠️ Build #${BUILD_NUMBER} is unstable\n${BUILD_URL}"
            )
        }
    }
}
```

## 🎯 Stage-level Post

### **Stage-specific Post Actions**
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
            post {
                always {
                    echo 'Build stage completed'
                }
                success {
                    echo 'Build stage succeeded'
                }
                failure {
                    echo 'Build stage failed'
                    archiveArtifacts artifacts: 'build.log', allowEmptyArchive: true
                }
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'target/site/jacoco',
                        reportFiles: 'index.html',
                        reportName: 'Coverage Report'
                    ])
                }
                failure {
                    echo 'Tests failed'
                    archiveArtifacts artifacts: 'target/surefire-reports/**', allowEmptyArchive: true
                }
            }
        }
    }
    post {
        always {
            echo 'Pipeline post actions'
            cleanWs()
        }
    }
}
```

## 📊 Common Post Actions

### **Artifact Management**
```groovy
post {
    always {
        // Archive build artifacts
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        
        // Archive logs
        archiveArtifacts artifacts: 'logs/**/*.log', allowEmptyArchive: true
        
        // Stash files for later use
        stash includes: 'target/*.jar', name: 'build-artifacts'
    }
}
```

### **Test Results**
```groovy
post {
    always {
        // JUnit test results
        junit 'target/surefire-reports/*.xml'
        
        // TestNG results
        publishTestNG reportFilenamePattern: 'target/testng-results.xml'
        
        // Coverage reports
        publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'coverage',
            reportFiles: 'index.html',
            reportName: 'Coverage Report'
        ])
    }
}
```

### **Notifications**
```groovy
post {
    success {
        // Slack notification
        slackSend(
            channel: '#deployments',
            color: 'good',
            message: "✅ ${JOB_NAME} #${BUILD_NUMBER} succeeded"
        )
        
        // Email notification
        emailext(
            subject: "Build Success: ${JOB_NAME}",
            body: "Build completed successfully",
            to: "${env.CHANGE_AUTHOR_EMAIL}"
        )
        
        // Teams notification
        office365ConnectorSend(
            webhookUrl: 'https://outlook.office.com/webhook/...',
            message: "Build ${BUILD_NUMBER} succeeded"
        )
    }
    
    failure {
        // Multiple notification channels
        parallel {
            'Slack': {
                slackSend(
                    color: 'danger',
                    message: "❌ ${JOB_NAME} #${BUILD_NUMBER} failed"
                )
            }
            'Email': {
                emailext(
                    subject: "Build Failed: ${JOB_NAME}",
                    body: "Build failed. Check ${BUILD_URL}console",
                    to: "${env.CHANGE_AUTHOR_EMAIL}"
                )
            }
            'Jira': {
                // Create Jira ticket for failures
                jiraCreateIssue(
                    site: 'jira-site',
                    issue: [
                        summary: "Build failure: ${JOB_NAME} #${BUILD_NUMBER}",
                        description: "Build failed. Console: ${BUILD_URL}console",
                        issueType: 'Bug'
                    ]
                )
            }
        }
    }
}
```

### **Cleanup Actions**
```groovy
post {
    always {
        // Clean workspace
        cleanWs()
        
        // Delete specific directories
        sh 'rm -rf tmp/'
        
        // Docker cleanup
        sh 'docker system prune -f'
        
        // Stop services
        sh 'docker-compose down || true'
    }
    
    cleanup {
        // Final cleanup after all other post actions
        deleteDir()  // Delete entire workspace directory
        
        // Custom cleanup script
        sh 'cleanup-script.sh || true'
    }
}
```

## 🔄 Conditional Post Actions

### **Environment-based Actions**
```groovy
post {
    success {
        script {
            if (env.BRANCH_NAME == 'main') {
                echo 'Deploying to production'
                sh 'deploy-to-production.sh'
            } else {
                echo 'Deploying to staging'
                sh 'deploy-to-staging.sh'
            }
        }
    }
}
```

### **Parameter-based Actions**
```groovy
pipeline {
    agent any
    parameters {
        booleanParam(name: 'NOTIFY_SLACK', defaultValue: true, description: 'Send Slack notifications')
        booleanParam(name: 'DEPLOY', defaultValue: false, description: 'Deploy after build')
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
    }
    post {
        success {
            script {
                if (params.NOTIFY_SLACK) {
                    slackSend color: 'good', message: 'Build succeeded'
                }
                if (params.DEPLOY) {
                    sh 'deploy.sh'
                }
            }
        }
    }
}
```

## 🎯 Advanced Post Patterns

### **Retry on Failure**
```groovy
post {
    failure {
        script {
            if (currentBuild.number <= 3) {  // Retry first 3 builds
                currentBuild.result = 'ABORTED'
                build job: env.JOB_NAME, parameters: [
                    string(name: 'RETRY_BUILD', value: 'true')
                ]
            }
        }
    }
}
```

### **Conditional Notifications**
```groovy
post {
    changed {
        script {
            def previousResult = currentBuild.previousBuild?.result
            def currentResult = currentBuild.result
            
            if (previousResult == 'FAILURE' && currentResult == 'SUCCESS') {
                slackSend color: 'good', message: '🎉 Build is now fixed!'
            } else if (previousResult == 'SUCCESS' && currentResult == 'FAILURE') {
                slackSend color: 'danger', message: '💥 Build just broke!'
            }
        }
    }
}
```

### **Metrics Collection**
```groovy
post {
    always {
        script {
            // Collect build metrics
            def buildDuration = currentBuild.duration
            def testResults = currentBuild.testResultAction
            
            // Send to monitoring system
            httpRequest(
                httpMode: 'POST',
                url: 'https://metrics.company.com/jenkins',
                requestBody: """
                {
                    "job": "${JOB_NAME}",
                    "build": ${BUILD_NUMBER},
                    "duration": ${buildDuration},
                    "result": "${currentBuild.result}",
                    "tests": {
                        "total": ${testResults?.totalCount ?: 0},
                        "failed": ${testResults?.failCount ?: 0}
                    }
                }
                """
            )
        }
    }
}
```

## 💡 Best Practices

### **1. Always Clean Up**
```groovy
post {
    always {
        cleanWs()  // Always clean workspace
    }
}
```

### **2. Handle All Scenarios**
```groovy
post {
    always { /* Common actions */ }
    success { /* Success notifications */ }
    failure { /* Failure handling */ }
    unstable { /* Test failure handling */ }
    aborted { /* Cleanup aborted builds */ }
}
```

### **3. Use Parallel Notifications**
```groovy
post {
    failure {
        parallel {
            'Slack': { slackSend(...) }
            'Email': { emailext(...) }
            'Jira': { jiraCreateIssue(...) }
        }
    }
}
```

### **4. Conditional Logic**
```groovy
post {
    success {
        script {
            if (env.BRANCH_NAME == 'main') {
                // Production deployment
            } else {
                // Staging deployment
            }
        }
    }
}
```