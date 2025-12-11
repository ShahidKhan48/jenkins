# Pipeline Parameters

## 📋 Parameter Types

### **String Parameters**
```groovy
pipeline {
    agent any
    
    parameters {
        string(
            name: 'VERSION',
            defaultValue: '1.0.0',
            description: 'Version to build and deploy'
        )
        string(
            name: 'BRANCH_NAME',
            defaultValue: 'main',
            description: 'Git branch to build'
        )
    }
    
    stages {
        stage('Build') {
            steps {
                echo "Building version: ${params.VERSION}"
                echo "From branch: ${params.BRANCH_NAME}"
            }
        }
    }
}
```

### **Choice Parameters**
```groovy
pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Target deployment environment'
        )
        choice(
            name: 'BUILD_TYPE',
            choices: ['debug', 'release'],
            description: 'Build configuration'
        )
    }
    
    stages {
        stage('Deploy') {
            steps {
                echo "Deploying to: ${params.ENVIRONMENT}"
                echo "Build type: ${params.BUILD_TYPE}"
                sh "deploy.sh --env=${params.ENVIRONMENT} --type=${params.BUILD_TYPE}"
            }
        }
    }
}
```

### **Boolean Parameters**
```groovy
pipeline {
    agent any
    
    parameters {
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Skip unit tests'
        )
        booleanParam(
            name: 'DEPLOY_TO_PROD',
            defaultValue: false,
            description: 'Deploy to production'
        )
        booleanParam(
            name: 'SEND_NOTIFICATIONS',
            defaultValue: true,
            description: 'Send build notifications'
        )
    }
    
    stages {
        stage('Test') {
            when {
                not { params.SKIP_TESTS }
            }
            steps {
                echo 'Running tests'
                sh 'npm test'
            }
        }
        
        stage('Production Deploy') {
            when {
                expression { params.DEPLOY_TO_PROD }
            }
            steps {
                echo 'Deploying to production'
                sh 'deploy-prod.sh'
            }
        }
    }
    
    post {
        always {
            script {
                if (params.SEND_NOTIFICATIONS) {
                    emailext subject: 'Build Complete', body: 'Build finished'
                }
            }
        }
    }
}
```

### **Text Parameters**
```groovy
pipeline {
    agent any
    
    parameters {
        text(
            name: 'DEPLOYMENT_NOTES',
            defaultValue: 'Standard deployment',
            description: 'Deployment notes and comments'
        )
        text(
            name: 'CONFIGURATION',
            defaultValue: '''
server.port=8080
database.url=jdbc:mysql://localhost:3306/app
            ''',
            description: 'Application configuration'
        )
    }
    
    stages {
        stage('Deploy') {
            steps {
                echo "Deployment notes: ${params.DEPLOYMENT_NOTES}"
                writeFile file: 'config.properties', text: params.CONFIGURATION
                sh 'cat config.properties'
            }
        }
    }
}
```

### **Password Parameters**
```groovy
pipeline {
    agent any
    
    parameters {
        password(
            name: 'DATABASE_PASSWORD',
            defaultValue: '',
            description: 'Database password'
        )
        password(
            name: 'API_KEY',
            defaultValue: '',
            description: 'External API key'
        )
    }
    
    stages {
        stage('Deploy') {
            steps {
                script {
                    // Use password parameters securely
                    withCredentials([
                        string(credentialsId: 'db-password', variable: 'DB_PASS')
                    ]) {
                        sh '''
                            export DB_PASSWORD="${DB_PASS}"
                            deploy-with-db.sh
                        '''
                    }
                }
            }
        }
    }
}
```

## 🔧 Advanced Parameter Usage

### **File Parameters**
```groovy
pipeline {
    agent any
    
    parameters {
        file(
            name: 'CONFIG_FILE',
            description: 'Upload configuration file'
        )
        file(
            name: 'DEPLOYMENT_PACKAGE',
            description: 'Upload deployment package'
        )
    }
    
    stages {
        stage('Process Files') {
            steps {
                script {
                    // Process uploaded files
                    if (params.CONFIG_FILE) {
                        sh "cp ${params.CONFIG_FILE} ./config/"
                    }
                    
                    if (params.DEPLOYMENT_PACKAGE) {
                        sh "unzip ${params.DEPLOYMENT_PACKAGE} -d ./deploy/"
                    }
                }
            }
        }
    }
}
```

### **Multi-Select Parameters**
```groovy
pipeline {
    agent any
    
    parameters {
        extendedChoice(
            name: 'SERVICES',
            type: 'PT_CHECKBOX',
            value: 'api,web,worker,database',
            description: 'Select services to deploy'
        )
    }
    
    stages {
        stage('Deploy Services') {
            steps {
                script {
                    def services = params.SERVICES.split(',')
                    
                    services.each { service ->
                        echo "Deploying service: ${service}"
                        sh "deploy-service.sh ${service}"
                    }
                }
            }
        }
    }
}
```

### **Cascading Parameters**
```groovy
pipeline {
    agent any
    
    parameters {
        choice(
            name: 'CLOUD_PROVIDER',
            choices: ['aws', 'azure', 'gcp'],
            description: 'Cloud provider'
        )
        choice(
            name: 'REGION',
            choices: ['us-east-1', 'us-west-2', 'eu-west-1'],
            description: 'Deployment region'
        )
        string(
            name: 'INSTANCE_TYPE',
            defaultValue: 't3.medium',
            description: 'Instance type'
        )
    }
    
    stages {
        stage('Validate Parameters') {
            steps {
                script {
                    // Validate parameter combinations
                    if (params.CLOUD_PROVIDER == 'aws' && !params.REGION.startsWith('us-')) {
                        error("Invalid region ${params.REGION} for AWS")
                    }
                    
                    if (params.CLOUD_PROVIDER == 'azure' && params.INSTANCE_TYPE.startsWith('t3')) {
                        error("Invalid instance type ${params.INSTANCE_TYPE} for Azure")
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh """
                    deploy.sh \\
                        --provider=${params.CLOUD_PROVIDER} \\
                        --region=${params.REGION} \\
                        --instance-type=${params.INSTANCE_TYPE}
                """
            }
        }
    }
}
```

## 🔄 Dynamic Parameters

### **Build-Time Parameter Generation**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Generate Parameters') {
            steps {
                script {
                    // Generate parameters based on environment
                    def branches = sh(
                        script: 'git branch -r | grep -v HEAD | sed "s/origin\\///"',
                        returnStdout: true
                    ).trim().split('\n')
                    
                    def environments = ['dev', 'staging']
                    
                    // Add production only for main branch
                    if (env.BRANCH_NAME == 'main') {
                        environments.add('prod')
                    }
                    
                    env.AVAILABLE_BRANCHES = branches.join(',')
                    env.AVAILABLE_ENVIRONMENTS = environments.join(',')
                }
            }
        }
        
        stage('Use Dynamic Parameters') {
            steps {
                script {
                    echo "Available branches: ${env.AVAILABLE_BRANCHES}"
                    echo "Available environments: ${env.AVAILABLE_ENVIRONMENTS}"
                }
            }
        }
    }
}
```

### **Parameter Validation**
```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'VERSION', defaultValue: '1.0.0', description: 'Semantic version')
        string(name: 'EMAIL', defaultValue: '', description: 'Notification email')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
    }
    
    stages {
        stage('Validate Parameters') {
            steps {
                script {
                    // Validate version format
                    if (!params.VERSION.matches(/^\d+\.\d+\.\d+$/)) {
                        error("Invalid version format: ${params.VERSION}. Expected: x.y.z")
                    }
                    
                    // Validate email format
                    if (params.EMAIL && !params.EMAIL.matches(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
                        error("Invalid email format: ${params.EMAIL}")
                    }
                    
                    // Environment-specific validations
                    if (params.ENVIRONMENT == 'prod' && env.BRANCH_NAME != 'main') {
                        error("Production deployment only allowed from main branch")
                    }
                    
                    echo "All parameters validated successfully"
                }
            }
        }
    }
}
```

## 📊 Parameter Best Practices

### **Default Values Strategy**
```groovy
pipeline {
    agent any
    
    parameters {
        // Always provide sensible defaults
        string(
            name: 'VERSION',
            defaultValue: env.BUILD_NUMBER ?: '1.0.0',
            description: 'Build version'
        )
        
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Target environment'
        )
        
        // Use environment-aware defaults
        booleanParam(
            name: 'RUN_TESTS',
            defaultValue: env.BRANCH_NAME != 'hotfix',
            description: 'Run test suite'
        )
    }
    
    stages {
        stage('Build') {
            steps {
                echo "Building version ${params.VERSION} for ${params.ENVIRONMENT}"
            }
        }
    }
}
```

### **Parameter Documentation**
```groovy
pipeline {
    agent any
    
    parameters {
        string(
            name: 'VERSION',
            defaultValue: '1.0.0',
            description: '''
                Semantic version number (x.y.z format)
                - x: Major version (breaking changes)
                - y: Minor version (new features)
                - z: Patch version (bug fixes)
            '''
        )
        
        choice(
            name: 'DEPLOYMENT_STRATEGY',
            choices: [
                'rolling:Rolling deployment (zero downtime)',
                'blue-green:Blue-green deployment (full switch)',
                'canary:Canary deployment (gradual rollout)'
            ],
            description: 'Deployment strategy with descriptions'
        )
    }
    
    stages {
        stage('Parse Parameters') {
            steps {
                script {
                    // Parse choice with description
                    def strategy = params.DEPLOYMENT_STRATEGY.split(':')[0]
                    echo "Using deployment strategy: ${strategy}"
                }
            }
        }
    }
}
```

### **Conditional Parameter Usage**
```groovy
pipeline {
    agent any
    
    parameters {
        choice(name: 'ACTION', choices: ['build', 'deploy', 'rollback'], description: 'Action to perform')
        string(name: 'VERSION', defaultValue: '', description: 'Version (required for deploy/rollback)')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Environment (for deploy/rollback)')
    }
    
    stages {
        stage('Validate Action Parameters') {
            steps {
                script {
                    if (params.ACTION in ['deploy', 'rollback']) {
                        if (!params.VERSION) {
                            error("VERSION parameter is required for ${params.ACTION} action")
                        }
                        if (!params.ENVIRONMENT) {
                            error("ENVIRONMENT parameter is required for ${params.ACTION} action")
                        }
                    }
                }
            }
        }
        
        stage('Execute Action') {
            steps {
                script {
                    switch(params.ACTION) {
                        case 'build':
                            sh 'make build'
                            break
                        case 'deploy':
                            sh "deploy.sh ${params.VERSION} ${params.ENVIRONMENT}"
                            break
                        case 'rollback':
                            sh "rollback.sh ${params.VERSION} ${params.ENVIRONMENT}"
                            break
                    }
                }
            }
        }
    }
}
```

## 🔍 Parameter Debugging

### **Parameter Inspection**
```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'DEBUG_LEVEL', defaultValue: 'INFO', description: 'Debug level')
        booleanParam(name: 'VERBOSE', defaultValue: false, description: 'Verbose output')
    }
    
    stages {
        stage('Debug Parameters') {
            steps {
                script {
                    echo "=== Parameter Debug Information ==="
                    echo "All parameters:"
                    params.each { key, value ->
                        echo "  ${key} = ${value} (${value.class.simpleName})"
                    }
                    
                    echo "\nEnvironment variables:"
                    env.getEnvironment().each { key, value ->
                        if (key.startsWith('PARAM_')) {
                            echo "  ${key} = ${value}"
                        }
                    }
                    
                    echo "\nBuild information:"
                    echo "  Build Number: ${env.BUILD_NUMBER}"
                    echo "  Branch Name: ${env.BRANCH_NAME}"
                    echo "  Build URL: ${env.BUILD_URL}"
                }
            }
        }
    }
}
```