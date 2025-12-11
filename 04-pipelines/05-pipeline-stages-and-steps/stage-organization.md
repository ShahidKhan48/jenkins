# Pipeline Stages and Steps

## 🏗️ Stage Organization

### **Basic Stage Structure**
```groovy
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
                sh 'make build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'make test'
            }
        }
    }
}
```

### **Sequential Stages**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Prepare') {
            steps {
                echo 'Preparing environment'
                sh 'mkdir -p build logs'
            }
        }
        
        stage('Compile') {
            steps {
                echo 'Compiling source code'
                sh 'javac -d build src/*.java'
            }
        }
        
        stage('Package') {
            steps {
                echo 'Creating JAR file'
                sh 'jar cf app.jar -C build .'
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying application'
                sh 'cp app.jar /opt/app/'
            }
        }
    }
}
```

## 🔄 Parallel Stages

### **Parallel Testing**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'make build'
            }
        }
        
        stage('Parallel Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm run test:unit'
                        publishTestResults testResultsPattern: 'reports/unit/*.xml'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh 'npm run test:integration'
                        publishTestResults testResultsPattern: 'reports/integration/*.xml'
                    }
                }
                stage('E2E Tests') {
                    steps {
                        sh 'npm run test:e2e'
                        publishTestResults testResultsPattern: 'reports/e2e/*.xml'
                    }
                }
                stage('Security Scan') {
                    steps {
                        sh 'npm audit'
                        sh 'snyk test'
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh 'make deploy'
            }
        }
    }
}
```

### **Multi-Platform Builds**
```groovy
pipeline {
    agent none
    
    stages {
        stage('Parallel Builds') {
            parallel {
                stage('Linux Build') {
                    agent { label 'linux' }
                    steps {
                        checkout scm
                        sh 'make build-linux'
                        archiveArtifacts artifacts: 'dist/linux/*'
                    }
                }
                stage('Windows Build') {
                    agent { label 'windows' }
                    steps {
                        checkout scm
                        bat 'make build-windows'
                        archiveArtifacts artifacts: 'dist/windows/*'
                    }
                }
                stage('macOS Build') {
                    agent { label 'macos' }
                    steps {
                        checkout scm
                        sh 'make build-macos'
                        archiveArtifacts artifacts: 'dist/macos/*'
                    }
                }
            }
        }
    }
}
```

## 📋 Step Types

### **Shell Commands**
```groovy
stage('Shell Commands') {
    steps {
        // Unix/Linux shell
        sh 'echo "Hello from bash"'
        sh '''
            echo "Multi-line shell script"
            ls -la
            pwd
        '''
        
        // Windows batch
        bat 'echo "Hello from Windows"'
        bat '''
            echo "Multi-line batch script"
            dir
            cd
        '''
        
        // PowerShell
        powershell 'Get-ChildItem'
        powershell '''
            Write-Host "Multi-line PowerShell"
            Get-Process | Where-Object {$_.Name -like "java*"}
        '''
    }
}
```

### **File Operations**
```groovy
stage('File Operations') {
    steps {
        // Read file content
        script {
            def content = readFile 'config.txt'
            echo "Config: ${content}"
        }
        
        // Write file
        writeFile file: 'output.txt', text: 'Build completed successfully'
        
        // Archive artifacts
        archiveArtifacts artifacts: '**/*.jar, **/*.war', fingerprint: true
        
        // Publish test results
        publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
        
        // Publish HTML reports
        publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'reports',
            reportFiles: 'index.html',
            reportName: 'Test Report'
        ])
    }
}
```

### **Build Steps**
```groovy
stage('Build Steps') {
    steps {
        // Checkout source code
        checkout scm
        
        // Checkout specific branch
        checkout([
            $class: 'GitSCM',
            branches: [[name: '*/develop']],
            userRemoteConfigs: [[url: 'https://github.com/user/repo.git']]
        ])
        
        // Build other jobs
        build job: 'upstream-job', parameters: [
            string(name: 'BRANCH', value: env.BRANCH_NAME)
        ]
        
        // Trigger downstream job
        build job: 'deploy-job', wait: false
    }
}
```

### **Conditional Steps**
```groovy
stage('Conditional Steps') {
    steps {
        script {
            if (env.BRANCH_NAME == 'main') {
                echo 'Running production deployment'
                sh 'deploy-prod.sh'
            } else {
                echo 'Running development deployment'
                sh 'deploy-dev.sh'
            }
        }
        
        // Using when directive (better approach)
    }
}

stage('Production Deploy') {
    when {
        branch 'main'
    }
    steps {
        echo 'Deploying to production'
        sh 'deploy-prod.sh'
    }
}
```

## 🔧 Advanced Stage Patterns

### **Matrix Builds**
```groovy
pipeline {
    agent none
    
    stages {
        stage('Matrix Build') {
            matrix {
                axes {
                    axis {
                        name 'PLATFORM'
                        values 'linux', 'windows', 'macos'
                    }
                    axis {
                        name 'JAVA_VERSION'
                        values '8', '11', '17'
                    }
                }
                excludes {
                    exclude {
                        axis {
                            name 'PLATFORM'
                            values 'windows'
                        }
                        axis {
                            name 'JAVA_VERSION'
                            values '8'
                        }
                    }
                }
                stages {
                    stage('Build') {
                        steps {
                            echo "Building on ${PLATFORM} with Java ${JAVA_VERSION}"
                            sh "build-${PLATFORM}-java${JAVA_VERSION}.sh"
                        }
                    }
                }
            }
        }
    }
}
```

### **Dynamic Stages**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Dynamic Stages') {
            steps {
                script {
                    def services = ['api', 'web', 'worker']
                    
                    for (service in services) {
                        stage("Build ${service}") {
                            echo "Building ${service}"
                            sh "build-${service}.sh"
                        }
                        
                        stage("Test ${service}") {
                            echo "Testing ${service}"
                            sh "test-${service}.sh"
                        }
                    }
                }
            }
        }
    }
}
```

### **Nested Parallel Stages**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            parallel {
                stage('Frontend') {
                    stages {
                        stage('Install Dependencies') {
                            steps {
                                sh 'npm install'
                            }
                        }
                        stage('Build Frontend') {
                            steps {
                                sh 'npm run build'
                            }
                        }
                        stage('Test Frontend') {
                            steps {
                                sh 'npm run test'
                            }
                        }
                    }
                }
                stage('Backend') {
                    stages {
                        stage('Compile') {
                            steps {
                                sh 'mvn compile'
                            }
                        }
                        stage('Test Backend') {
                            steps {
                                sh 'mvn test'
                            }
                        }
                        stage('Package') {
                            steps {
                                sh 'mvn package'
                            }
                        }
                    }
                }
            }
        }
    }
}
```

## 📊 Stage Options

### **Timeout and Retry**
```groovy
stage('Flaky Test') {
    options {
        timeout(time: 10, unit: 'MINUTES')
        retry(3)
    }
    steps {
        sh 'run-flaky-test.sh'
    }
}
```

### **Skip Checkout**
```groovy
stage('No Checkout Needed') {
    options {
        skipDefaultCheckout()
    }
    steps {
        echo 'This stage does not need source code'
    }
}
```

### **Timestamps**
```groovy
stage('With Timestamps') {
    options {
        timestamps()
    }
    steps {
        sh 'long-running-command.sh'
    }
}
```

## 🔍 Stage Monitoring

### **Stage Status**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Monitor Stage') {
            steps {
                script {
                    echo "Current stage: ${env.STAGE_NAME}"
                    echo "Build number: ${env.BUILD_NUMBER}"
                    echo "Build URL: ${env.BUILD_URL}"
                }
            }
        }
    }
    
    post {
        always {
            script {
                def stages = currentBuild.rawBuild.getAction(org.jenkinsci.plugins.workflow.job.views.FlowGraphAction.class)
                stages?.getNodes()?.each { node ->
                    echo "Stage: ${node.getDisplayName()}, Status: ${node.getError()}"
                }
            }
        }
    }
}
```

### **Performance Tracking**
```groovy
stage('Performance Tracking') {
    steps {
        script {
            def startTime = System.currentTimeMillis()
            
            sh 'run-performance-test.sh'
            
            def endTime = System.currentTimeMillis()
            def duration = (endTime - startTime) / 1000
            
            echo "Performance test completed in ${duration} seconds"
            
            if (duration > 300) {
                unstable("Performance test took too long: ${duration}s")
            }
        }
    }
}
```

## 📋 Best Practices

### **Stage Naming**
- Use descriptive, action-oriented names
- Keep names concise but clear
- Use consistent naming conventions
- Avoid special characters

### **Stage Organization**
- Group related steps in single stages
- Use parallel stages for independent tasks
- Keep stages focused and atomic
- Consider stage dependencies

### **Error Handling**
- Use post sections for cleanup
- Implement proper error reporting
- Consider stage-level error handling
- Use unstable() for warnings