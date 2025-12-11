# Creating a Jenkinsfile

## 📝 What is a Jenkinsfile?

A Jenkinsfile is a text file that contains the definition of a Jenkins Pipeline and is checked into source control.

## 🎯 Basic Jenkinsfile Structure

```groovy
pipeline {
    agent any
    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
    }
}
```

## 📁 File Location

### **Repository Root**
```
my-project/
├── src/
├── pom.xml
└── Jenkinsfile  ← Place here
```

### **Custom Path**
```groovy
// In Pipeline job configuration
Pipeline script from SCM
Script Path: ci/Jenkinsfile
```

## 🚀 Step-by-Step Creation

### **Step 1: Create Basic Structure**
```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
    }
}
```

### **Step 2: Add Build Stage**
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
                sh 'mvn clean compile'
            }
        }
    }
}
```

### **Step 3: Add Test Stage**
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
                sh 'mvn clean compile'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
    }
}
```

## 🔧 Complete Example

```groovy
pipeline {
    agent any
    
    tools {
        maven 'Maven-3.8.1'
        jdk 'JDK-11'
    }
    
    environment {
        MAVEN_OPTS = '-Xmx1024m'
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
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'echo "Deploying to production"'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

## 💡 Best Practices

### **1. Start Simple**
```groovy
pipeline {
    agent any
    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
    }
}
```

### **2. Use Version Control**
- Always commit Jenkinsfile to repository
- Use meaningful commit messages
- Review changes through pull requests

### **3. Test Locally**
```bash
# Validate syntax
jenkins-cli declarative-linter < Jenkinsfile
```

### **4. Use Comments**
```groovy
pipeline {
    agent any
    stages {
        // Build the application
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
    }
}
```