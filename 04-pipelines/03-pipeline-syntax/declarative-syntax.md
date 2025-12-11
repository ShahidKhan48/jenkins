# Declarative Pipeline Syntax

## 📝 Basic Structure

```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
    }
}
```

## 🔧 Required Sections

### **Pipeline Block**
```groovy
pipeline {
    // All pipeline content goes here
}
```

### **Agent Directive**
```groovy
// Any available agent
agent any

// Specific label
agent { label 'linux' }

// Docker agent
agent {
    docker {
        image 'node:18'
    }
}

// No agent (stages define their own)
agent none
```

### **Stages Section**
```groovy
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
```

## 📊 Optional Sections

### **Environment Variables**
```groovy
pipeline {
    agent any
    
    environment {
        JAVA_HOME = '/usr/lib/jvm/java-11'
        PATH = "${env.PATH}:${env.JAVA_HOME}/bin"
        DEBUG = 'true'
    }
    
    stages {
        stage('Build') {
            environment {
                BUILD_TYPE = 'release'
            }
            steps {
                echo "Java Home: ${JAVA_HOME}"
                echo "Build Type: ${BUILD_TYPE}"
            }
        }
    }
}
```

### **Parameters**
```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'VERSION', defaultValue: '1.0.0', description: 'Version to build')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip tests')
    }
    
    stages {
        stage('Build') {
            steps {
                echo "Building version: ${params.VERSION}"
                echo "Target environment: ${params.ENVIRONMENT}"
            }
        }
    }
}
```

### **Triggers**
```groovy
pipeline {
    agent any
    
    triggers {
        cron('H 2 * * *')  // Daily at 2 AM
        pollSCM('H/5 * * * *')  // Poll every 5 minutes
        upstream(upstreamProjects: 'upstream-job', threshold: hudson.model.Result.SUCCESS)
    }
    
    stages {
        stage('Build') {
            steps {
                echo 'Triggered build'
            }
        }
    }
}
```

### **Tools**
```groovy
pipeline {
    agent any
    
    tools {
        maven 'Maven-3.8.6'
        jdk 'JDK-11'
        nodejs 'NodeJS-18'
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'mvn --version'
                sh 'java -version'
                sh 'node --version'
            }
        }
    }
}
```

## 🔄 Advanced Directives

### **When Conditions**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                echo 'Deploying to staging'
            }
        }
        
        stage('Deploy to Production') {
            when {
                allOf {
                    branch 'main'
                    environment name: 'DEPLOY_PROD', value: 'true'
                }
            }
            steps {
                echo 'Deploying to production'
            }
        }
    }
}
```

### **Parallel Execution**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Parallel Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm run test:unit'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh 'npm run test:integration'
                    }
                }
                stage('E2E Tests') {
                    steps {
                        sh 'npm run test:e2e'
                    }
                }
            }
        }
    }
}
```

### **Matrix Builds**
```groovy
pipeline {
    agent none
    
    stages {
        stage('Build Matrix') {
            matrix {
                axes {
                    axis {
                        name 'PLATFORM'
                        values 'linux', 'windows', 'mac'
                    }
                    axis {
                        name 'BROWSER'
                        values 'chrome', 'firefox', 'safari'
                    }
                }
                stages {
                    stage('Test') {
                        steps {
                            echo "Testing on ${PLATFORM} with ${BROWSER}"
                        }
                    }
                }
            }
        }
    }
}
```

## 📋 Post Actions

```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
    }
    
    post {
        always {
            echo 'This runs regardless of result'
            cleanWs()
        }
        success {
            echo 'This runs only if successful'
            emailext subject: 'Build Success', body: 'Build completed successfully'
        }
        failure {
            echo 'This runs only if failed'
            emailext subject: 'Build Failed', body: 'Build failed'
        }
        unstable {
            echo 'This runs if build is unstable'
        }
        changed {
            echo 'This runs if build result changed from previous'
        }
    }
}
```

## 🔧 Complete Example

```groovy
pipeline {
    agent {
        docker {
            image 'maven:3.8.6-openjdk-11'
            args '-v /root/.m2:/root/.m2'
        }
    }
    
    environment {
        MAVEN_OPTS = '-Xmx1024m'
        SONAR_TOKEN = credentials('sonar-token')
    }
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip unit tests')
    }
    
    triggers {
        pollSCM('H/5 * * * *')
    }
    
    tools {
        maven 'Maven-3.8.6'
        jdk 'JDK-11'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            when {
                not { params.SKIP_TESTS }
            }
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'mvn test'
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                        }
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh 'mvn verify -Dskip.unit.tests=true'
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
        
        stage('Deploy') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                script {
                    def targetEnv = params.ENVIRONMENT ?: (env.BRANCH_NAME == 'main' ? 'prod' : 'dev')
                    echo "Deploying to ${targetEnv}"
                    
                    if (targetEnv == 'prod') {
                        input message: 'Deploy to production?', ok: 'Deploy'
                    }
                    
                    sh "deploy.sh ${targetEnv}"
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            emailext (
                subject: "✅ Build Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build completed successfully for ${env.BRANCH_NAME}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
        failure {
            emailext (
                subject: "❌ Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build failed for ${env.BRANCH_NAME}. Check console output: ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```