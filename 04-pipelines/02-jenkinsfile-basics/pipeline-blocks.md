# Pipeline Blocks

## 🧩 Core Pipeline Blocks

### **1. Pipeline Block**
The root element that defines the entire pipeline.

```groovy
pipeline {
    // All pipeline content goes here
}
```

### **2. Agent Block**
Specifies where the pipeline will execute.

```groovy
pipeline {
    agent any  // Run on any available agent
    // or
    agent none  // Don't allocate agent globally
    // or
    agent {
        label 'linux'  // Run on agents with 'linux' label
    }
}
```

### **3. Stages Block**
Contains a sequence of one or more stage directives.

```groovy
pipeline {
    agent any
    stages {
        stage('Build') { /* ... */ }
        stage('Test') { /* ... */ }
        stage('Deploy') { /* ... */ }
    }
}
```

### **4. Stage Block**
Defines a conceptually distinct subset of tasks.

```groovy
stage('Build') {
    steps {
        sh 'mvn clean compile'
    }
}
```

### **5. Steps Block**
Contains one or more build steps.

```groovy
steps {
    echo 'Starting build'
    sh 'mvn clean compile'
    echo 'Build completed'
}
```

## 🔧 Optional Blocks

### **Environment Block**
Defines environment variables.

```groovy
pipeline {
    agent any
    environment {
        MAVEN_OPTS = '-Xmx1024m'
        BUILD_VERSION = '1.0.0'
        PATH = "/opt/custom/bin:${env.PATH}"
    }
    stages {
        stage('Build') {
            steps {
                sh 'echo $BUILD_VERSION'
            }
        }
    }
}
```

### **Tools Block**
Defines tools to auto-install and put on PATH.

```groovy
pipeline {
    agent any
    tools {
        maven 'Maven-3.8.1'
        jdk 'JDK-11'
        nodejs 'NodeJS-16'
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

### **Parameters Block**
Defines build parameters.

```groovy
pipeline {
    agent any
    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build')
        booleanParam(name: 'DEPLOY', defaultValue: false, description: 'Deploy to production')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
    }
    stages {
        stage('Build') {
            steps {
                echo "Building branch: ${params.BRANCH}"
                echo "Deploy flag: ${params.DEPLOY}"
                echo "Environment: ${params.ENVIRONMENT}"
            }
        }
    }
}
```

### **Triggers Block**
Defines build triggers.

```groovy
pipeline {
    agent any
    triggers {
        cron('H 2 * * *')  // Daily at 2 AM
        pollSCM('H/5 * * * *')  // Poll SCM every 5 minutes
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

### **Options Block**
Defines pipeline-specific options.

```groovy
pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
        skipDefaultCheckout()
        retry(3)
    }
    stages {
        stage('Build') {
            steps {
                echo 'Building with options'
            }
        }
    }
}
```

### **Post Block**
Defines actions to run at the end of pipeline execution.

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
    }
    post {
        always {
            echo 'This will always run'
            cleanWs()
        }
        success {
            echo 'This will run only if successful'
        }
        failure {
            echo 'This will run only if failed'
        }
        unstable {
            echo 'This will run only if unstable'
        }
        changed {
            echo 'This will run only if state changed'
        }
    }
}
```

## 🎯 Block Hierarchy

```groovy
pipeline {                    // Root block
    agent any                 // Agent block
    
    environment { }           // Environment block
    tools { }                 // Tools block
    parameters { }            // Parameters block
    triggers { }              // Triggers block
    options { }               // Options block
    
    stages {                  // Stages block
        stage('Build') {      // Stage block
            environment { }   // Stage-level environment
            tools { }         // Stage-level tools
            when { }          // When block
            steps { }         // Steps block
            post { }          // Stage-level post
        }
    }
    
    post { }                  // Pipeline-level post
}
```

## 📊 Block Scope

### **Global Scope**
```groovy
pipeline {
    agent any
    environment {
        GLOBAL_VAR = 'available everywhere'
    }
    stages {
        stage('Test') {
            steps {
                echo "${env.GLOBAL_VAR}"  // Works
            }
        }
    }
}
```

### **Stage Scope**
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            environment {
                STAGE_VAR = 'only in this stage'
            }
            steps {
                echo "${env.STAGE_VAR}"  // Works
            }
        }
        stage('Test') {
            steps {
                echo "${env.STAGE_VAR}"  // Doesn't work
            }
        }
    }
}
```

## 💡 Best Practices

### **1. Logical Organization**
```groovy
pipeline {
    // Configuration blocks first
    agent any
    environment { }
    tools { }
    parameters { }
    
    // Main pipeline logic
    stages { }
    
    // Cleanup and notifications last
    post { }
}
```

### **2. Use Meaningful Names**
```groovy
stages {
    stage('Compile Source Code') { }
    stage('Run Unit Tests') { }
    stage('Build Docker Image') { }
    stage('Deploy to Staging') { }
}
```

### **3. Keep Blocks Focused**
```groovy
// Good - focused stage
stage('Test') {
    steps {
        sh 'mvn test'
    }
    post {
        always {
            junit 'target/surefire-reports/*.xml'
        }
    }
}
```