# Environment Section

## 🌍 Environment Variables in Pipelines

The environment section defines environment variables that are available to all steps in the pipeline or stage.

## 🎯 Global Environment

### **Pipeline Level**
```groovy
pipeline {
    agent any
    environment {
        MAVEN_OPTS = '-Xmx1024m'
        BUILD_VERSION = '1.0.0'
        DEPLOY_ENV = 'staging'
    }
    stages {
        stage('Build') {
            steps {
                echo "Maven opts: ${env.MAVEN_OPTS}"
                echo "Build version: ${env.BUILD_VERSION}"
                sh 'echo $DEPLOY_ENV'
            }
        }
    }
}
```

### **Stage Level**
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            environment {
                COMPILE_FLAGS = '-O2 -Wall'
                BUILD_TYPE = 'release'
            }
            steps {
                echo "Compile flags: ${env.COMPILE_FLAGS}"
                sh 'echo $BUILD_TYPE'
            }
        }
        stage('Test') {
            environment {
                TEST_ENV = 'unit'
                PARALLEL_JOBS = '4'
            }
            steps {
                echo "Test environment: ${env.TEST_ENV}"
                sh 'echo "Running with $PARALLEL_JOBS parallel jobs"'
            }
        }
    }
}
```

## 🔧 Environment Variable Types

### **String Variables**
```groovy
environment {
    APP_NAME = 'my-application'
    VERSION = '2.1.0'
    ENVIRONMENT = 'production'
}
```

### **Computed Variables**
```groovy
environment {
    BUILD_TIMESTAMP = sh(script: 'date +%Y%m%d-%H%M%S', returnStdout: true).trim()
    GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    BUILD_NUMBER_PADDED = String.format('%04d', BUILD_NUMBER as Integer)
}
```

### **Conditional Variables**
```groovy
environment {
    DEPLOY_TARGET = "${env.BRANCH_NAME == 'main' ? 'production' : 'staging'}"
    DEBUG_MODE = "${params.DEBUG ?: 'false'}"
}
```

### **Path Variables**
```groovy
environment {
    PATH = "/opt/custom/bin:${env.PATH}"
    JAVA_HOME = '/usr/lib/jvm/java-11-openjdk'
    MAVEN_HOME = '/opt/maven'
    CUSTOM_PATH = "${env.WORKSPACE}/tools/bin"
}
```

## 🔐 Credentials in Environment

### **Using Credentials**
```groovy
pipeline {
    agent any
    environment {
        // Username/password credentials
        DATABASE_CREDS = credentials('database-credentials')
        
        // Secret text
        API_KEY = credentials('api-key')
        
        // SSH key
        SSH_KEY = credentials('ssh-private-key')
        
        // Certificate
        CERT_FILE = credentials('ssl-certificate')
    }
    stages {
        stage('Deploy') {
            steps {
                // Credentials are automatically masked in logs
                sh '''
                    echo "Connecting to database..."
                    mysql -u $DATABASE_CREDS_USR -p$DATABASE_CREDS_PSW
                '''
                
                sh '''
                    curl -H "Authorization: Bearer $API_KEY" \
                         https://api.example.com/deploy
                '''
            }
        }
    }
}
```

### **Credential Types**
```groovy
environment {
    // Username/Password → Creates _USR and _PSW variables
    DB_CREDS = credentials('db-credentials')
    // Available as: DB_CREDS_USR, DB_CREDS_PSW
    
    // Secret Text → Single variable
    SECRET_TOKEN = credentials('secret-token')
    
    // SSH Username with private key → Creates _USR and _PSW variables
    SSH_CREDS = credentials('ssh-key')
    // Available as: SSH_CREDS_USR, SSH_CREDS_PSW (passphrase)
    
    // Certificate → File path
    CERT = credentials('certificate')
    // Available as file path
}
```

## 🎯 Built-in Environment Variables

### **Jenkins Built-ins**
```groovy
pipeline {
    agent any
    stages {
        stage('Info') {
            steps {
                echo "Build Number: ${env.BUILD_NUMBER}"
                echo "Build ID: ${env.BUILD_ID}"
                echo "Job Name: ${env.JOB_NAME}"
                echo "Build URL: ${env.BUILD_URL}"
                echo "Jenkins URL: ${env.JENKINS_URL}"
                echo "Workspace: ${env.WORKSPACE}"
                echo "Node Name: ${env.NODE_NAME}"
            }
        }
    }
}
```

### **SCM Variables**
```groovy
pipeline {
    agent any
    stages {
        stage('SCM Info') {
            steps {
                echo "Branch: ${env.BRANCH_NAME}"
                echo "Change ID: ${env.CHANGE_ID}"
                echo "Change URL: ${env.CHANGE_URL}"
                echo "Change Title: ${env.CHANGE_TITLE}"
                echo "Change Author: ${env.CHANGE_AUTHOR}"
                echo "Git Commit: ${env.GIT_COMMIT}"
                echo "Git URL: ${env.GIT_URL}"
            }
        }
    }
}
```

## 🔄 Dynamic Environment Variables

### **Using Script Block**
```groovy
pipeline {
    agent any
    environment {
        DYNAMIC_VAR = "${sh(script: 'echo "dynamic-$(date +%s)"', returnStdout: true).trim()}"
        GIT_SHORT_COMMIT = "${sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()}"
    }
    stages {
        stage('Build') {
            steps {
                echo "Dynamic variable: ${env.DYNAMIC_VAR}"
                echo "Git commit: ${env.GIT_SHORT_COMMIT}"
            }
        }
    }
}
```

### **Stage-specific Dynamic Variables**
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            environment {
                BUILD_TIME = "${sh(script: 'date', returnStdout: true).trim()}"
                ARTIFACT_NAME = "app-${BUILD_NUMBER}-${GIT_COMMIT[0..7]}.jar"
            }
            steps {
                echo "Build started at: ${env.BUILD_TIME}"
                echo "Artifact will be: ${env.ARTIFACT_NAME}"
            }
        }
    }
}
```

## 📊 Environment Variable Scope

### **Scope Hierarchy**
```groovy
pipeline {
    agent any
    environment {
        GLOBAL_VAR = 'available everywhere'
        OVERRIDE_ME = 'global value'
    }
    stages {
        stage('Stage 1') {
            environment {
                STAGE_VAR = 'only in stage 1'
                OVERRIDE_ME = 'stage value'  // Overrides global
            }
            steps {
                echo "Global: ${env.GLOBAL_VAR}"      // Works
                echo "Stage: ${env.STAGE_VAR}"        // Works
                echo "Override: ${env.OVERRIDE_ME}"   // Shows 'stage value'
            }
        }
        stage('Stage 2') {
            steps {
                echo "Global: ${env.GLOBAL_VAR}"      // Works
                echo "Stage: ${env.STAGE_VAR}"        // Empty/undefined
                echo "Override: ${env.OVERRIDE_ME}"   // Shows 'global value'
            }
        }
    }
}
```

## 🛠️ Advanced Environment Patterns

### **Conditional Environment**
```groovy
pipeline {
    agent any
    environment {
        DEPLOY_ENV = "${env.BRANCH_NAME == 'main' ? 'production' : 'staging'}"
        DEBUG_ENABLED = "${params.ENABLE_DEBUG == true ? 'true' : 'false'}"
        PARALLEL_JOBS = "${env.NODE_NAME.contains('high-cpu') ? '8' : '4'}"
    }
    stages {
        stage('Deploy') {
            steps {
                echo "Deploying to: ${env.DEPLOY_ENV}"
                echo "Debug mode: ${env.DEBUG_ENABLED}"
                echo "Parallel jobs: ${env.PARALLEL_JOBS}"
            }
        }
    }
}
```

### **Environment from Files**
```groovy
pipeline {
    agent any
    stages {
        stage('Load Config') {
            steps {
                script {
                    // Load environment from file
                    def props = readProperties file: 'config.properties'
                    env.DATABASE_URL = props.database_url
                    env.API_ENDPOINT = props.api_endpoint
                }
            }
        }
        stage('Use Config') {
            steps {
                echo "Database: ${env.DATABASE_URL}"
                echo "API: ${env.API_ENDPOINT}"
            }
        }
    }
}
```

### **Environment Templates**
```groovy
pipeline {
    agent any
    environment {
        // Template variables
        APP_NAME = 'my-app'
        VERSION = "${BUILD_NUMBER}"
        
        // Computed from template
        DOCKER_IMAGE = "${APP_NAME}:${VERSION}"
        DEPLOYMENT_NAME = "${APP_NAME}-${env.BRANCH_NAME}"
        CONFIG_FILE = "${APP_NAME}-${env.BRANCH_NAME}.yaml"
    }
    stages {
        stage('Build') {
            steps {
                echo "Building: ${env.DOCKER_IMAGE}"
                echo "Deployment: ${env.DEPLOYMENT_NAME}"
                echo "Config: ${env.CONFIG_FILE}"
            }
        }
    }
}
```

## 💡 Best Practices

### **1. Use Meaningful Names**
```groovy
environment {
    // Good
    DATABASE_CONNECTION_STRING = 'jdbc:mysql://db:3306/app'
    DOCKER_REGISTRY_URL = 'registry.company.com'
    
    // Bad
    VAR1 = 'some value'
    X = 'registry.company.com'
}
```

### **2. Group Related Variables**
```groovy
environment {
    // Database configuration
    DB_HOST = 'localhost'
    DB_PORT = '5432'
    DB_NAME = 'myapp'
    
    // Docker configuration
    DOCKER_REGISTRY = 'registry.company.com'
    DOCKER_NAMESPACE = 'myteam'
    DOCKER_TAG = "${BUILD_NUMBER}"
}
```

### **3. Use Stage-specific Variables**
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            environment {
                MAVEN_OPTS = '-Xmx2g'
                COMPILE_FLAGS = '-O2'
            }
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('Test') {
            environment {
                TEST_PARALLEL = '4'
                TEST_TIMEOUT = '300'
            }
            steps {
                sh 'mvn test -Dparallel=${TEST_PARALLEL}'
            }
        }
    }
}
```

### **4. Secure Sensitive Data**
```groovy
environment {
    // Use credentials() for sensitive data
    API_KEY = credentials('api-key')
    DB_PASSWORD = credentials('db-password')
    
    // Not credentials for non-sensitive data
    APP_VERSION = '1.0.0'
    BUILD_TYPE = 'release'
}
```