# Declarative vs Scripted Pipelines

## 📊 Overview Comparison

| Feature | Declarative | Scripted |
|---------|-------------|----------|
| **Syntax** | Structured, YAML-like | Groovy code |
| **Learning Curve** | Easier | Steeper |
| **Flexibility** | Limited but sufficient | Full Groovy power |
| **Error Handling** | Built-in | Manual |
| **Validation** | Pre-execution | Runtime |

## 🏗️ Declarative Pipeline

### **Structure**
```groovy
pipeline {
    agent any
    
    environment {
        VAR = 'value'
    }
    
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
```

### **Advantages**
- **Structured syntax** - Predefined sections and validation
- **Easier to read** - Clear, declarative structure
- **Built-in features** - Error handling, retry, timeout
- **IDE support** - Better syntax highlighting and validation
- **Recommended approach** - Jenkins team recommendation

### **Limitations**
- **Less flexible** - Cannot use arbitrary Groovy code
- **Script blocks needed** - For complex logic
- **Limited control flow** - Restricted programming constructs

## 🔧 Scripted Pipeline

### **Structure**
```groovy
node {
    try {
        stage('Checkout') {
            checkout scm
        }
        
        stage('Build') {
            sh 'make build'
        }
        
        stage('Test') {
            sh 'make test'
        }
        
    } catch (Exception e) {
        currentBuild.result = 'FAILURE'
        throw e
    } finally {
        cleanWs()
    }
}
```

### **Advantages**
- **Full flexibility** - Complete Groovy programming language
- **Dynamic behavior** - Runtime decisions and complex logic
- **No restrictions** - Any Groovy/Java libraries
- **Legacy support** - Older Jenkins versions

### **Limitations**
- **Complex syntax** - Requires Groovy knowledge
- **Manual error handling** - No built-in retry/timeout
- **Harder to maintain** - More verbose and complex
- **Security concerns** - Full script execution power

## 🔄 Migration Examples

### **Simple Build - Scripted**
```groovy
node {
    stage('Checkout') {
        checkout scm
    }
    
    stage('Build') {
        sh 'mvn clean package'
    }
    
    stage('Test') {
        sh 'mvn test'
        publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
    }
    
    stage('Archive') {
        archiveArtifacts artifacts: 'target/*.jar'
    }
}
```

### **Same Build - Declarative**
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
                sh 'mvn clean package'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar'
            }
        }
    }
}
```

## 🔧 Complex Logic Handling

### **Scripted - Dynamic Stages**
```groovy
node {
    def environments = ['dev', 'staging', 'prod']
    
    stage('Build') {
        sh 'make build'
    }
    
    for (env in environments) {
        stage("Deploy to ${env}") {
            if (env == 'prod' && env.BRANCH_NAME != 'main') {
                echo "Skipping prod deployment for ${env.BRANCH_NAME}"
                continue
            }
            
            timeout(time: 5, unit: 'MINUTES') {
                input message: "Deploy to ${env}?", ok: 'Deploy'
            }
            
            sh "deploy.sh ${env}"
        }
    }
}
```

### **Declarative - Script Block**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'make build'
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    def environments = ['dev', 'staging', 'prod']
                    
                    for (env in environments) {
                        if (env == 'prod' && env.BRANCH_NAME != 'main') {
                            echo "Skipping prod deployment for ${env.BRANCH_NAME}"
                            continue
                        }
                        
                        timeout(time: 5, unit: 'MINUTES') {
                            input message: "Deploy to ${env}?", ok: 'Deploy'
                        }
                        
                        sh "deploy.sh ${env}"
                    }
                }
            }
        }
    }
}
```

## 📋 When to Use Each

### **Use Declarative When:**
- ✅ Standard CI/CD workflows
- ✅ Team has mixed skill levels
- ✅ Need built-in features (retry, timeout)
- ✅ Want Jenkins best practices
- ✅ Starting new projects

### **Use Scripted When:**
- ✅ Complex conditional logic needed
- ✅ Dynamic pipeline generation
- ✅ Legacy pipeline migration
- ✅ Advanced Groovy features required
- ✅ Existing scripted pipelines

## 🔄 Hybrid Approach

### **Declarative with Script Blocks**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'make build'
            }
        }
        
        stage('Complex Logic') {
            steps {
                script {
                    // Complex Groovy logic here
                    def config = readJSON file: 'config.json'
                    
                    config.services.each { service ->
                        if (service.enabled) {
                            sh "deploy-service.sh ${service.name}"
                        }
                    }
                }
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

## 📊 Performance Comparison

### **Startup Time**
- **Declarative**: Faster validation and startup
- **Scripted**: Slower due to Groovy compilation

### **Memory Usage**
- **Declarative**: Lower memory footprint
- **Scripted**: Higher due to full Groovy runtime

### **Execution Speed**
- **Declarative**: Optimized execution path
- **Scripted**: Depends on code complexity

## 🛠️ Best Practices

### **Declarative Best Practices**
```groovy
pipeline {
    agent none  // Define agents per stage for efficiency
    
    options {
        timeout(time: 1, unit: 'HOURS')
        retry(3)
        skipDefaultCheckout()
    }
    
    stages {
        stage('Parallel Build') {
            parallel {
                stage('Linux Build') {
                    agent { label 'linux' }
                    steps {
                        checkout scm
                        sh 'make build-linux'
                    }
                }
                stage('Windows Build') {
                    agent { label 'windows' }
                    steps {
                        checkout scm
                        bat 'make build-windows'
                    }
                }
            }
        }
    }
}
```

### **Scripted Best Practices**
```groovy
def buildStage(platform) {
    return {
        node(platform) {
            try {
                checkout scm
                sh "make build-${platform}"
            } catch (Exception e) {
                currentBuild.result = 'FAILURE'
                throw e
            } finally {
                cleanWs()
            }
        }
    }
}

parallel(
    'linux': buildStage('linux'),
    'windows': buildStage('windows')
)
```

## 📋 Migration Checklist

### **Scripted to Declarative**
- [ ] Identify complex logic for script blocks
- [ ] Convert node blocks to agent directives
- [ ] Move try/catch to post sections
- [ ] Convert parallel closures to parallel stages
- [ ] Add proper when conditions
- [ ] Test thoroughly in non-production environment