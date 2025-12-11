# Pipeline Syntax Errors

## 🚨 Common Syntax Errors

Pipeline syntax errors prevent builds from starting and require immediate attention to restore functionality.

## 📝 Jenkinsfile Syntax Issues

### **Missing Brackets and Braces**
```groovy
// ❌ Incorrect - Missing closing brace
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        // Missing closing brace for stage
    }
}

// ✅ Correct
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

### **Incorrect Indentation**
```groovy
// ❌ Incorrect - Wrong indentation
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

// ✅ Correct - Proper indentation
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

### **Missing Required Sections**
```groovy
// ❌ Incorrect - Missing agent
pipeline {
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
    }
}

// ✅ Correct - Agent specified
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

## 🔧 Step Syntax Errors

### **Incorrect Step Usage**
```groovy
// ❌ Incorrect - Wrong step syntax
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'echo "Hello"'
                bat 'echo "Hello"'  // Wrong OS
            }
        }
    }
}

// ✅ Correct - OS-specific steps
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'echo "Hello"'
                    } else {
                        bat 'echo "Hello"'
                    }
                }
            }
        }
    }
}
```

### **String Quoting Issues**
```groovy
// ❌ Incorrect - Unescaped quotes
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'echo "Hello "World""'  // Syntax error
            }
        }
    }
}

// ✅ Correct - Proper escaping
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'echo "Hello \\"World\\""'
                // Or use single quotes
                sh "echo 'Hello \"World\"'"
            }
        }
    }
}
```

## 🔄 Control Flow Errors

### **Incorrect Conditional Syntax**
```groovy
// ❌ Incorrect - Wrong when syntax
pipeline {
    agent any
    stages {
        stage('Deploy') {
            when {
                branch = 'main'  // Wrong syntax
            }
            steps {
                echo 'Deploying...'
            }
        }
    }
}

// ✅ Correct - Proper when syntax
pipeline {
    agent any
    stages {
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo 'Deploying...'
            }
        }
    }
}
```

### **Parallel Stage Errors**
```groovy
// ❌ Incorrect - Wrong parallel syntax
pipeline {
    agent any
    stages {
        stage('Parallel Tests') {
            parallel {
                'Unit Tests': {
                    echo 'Running unit tests'
                },
                'Integration Tests': {
                    echo 'Running integration tests'
                }
            }
        }
    }
}

// ✅ Correct - Proper parallel syntax
pipeline {
    agent any
    stages {
        stage('Parallel Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        echo 'Running unit tests'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        echo 'Running integration tests'
                    }
                }
            }
        }
    }
}
```

## 📊 Parameter and Variable Errors

### **Parameter Definition Issues**
```groovy
// ❌ Incorrect - Wrong parameter syntax
pipeline {
    agent any
    parameters {
        string(name: 'VERSION', defaultValue: '1.0.0', description: 'Version to build')
        choice(name: 'ENVIRONMENT', choices: 'dev\nstaging\nprod', description: 'Target environment')
    }
    stages {
        stage('Build') {
            steps {
                echo "Building version ${VERSION}"  // Wrong variable reference
            }
        }
    }
}

// ✅ Correct - Proper parameter usage
pipeline {
    agent any
    parameters {
        string(name: 'VERSION', defaultValue: '1.0.0', description: 'Version to build')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
    }
    stages {
        stage('Build') {
            steps {
                echo "Building version ${params.VERSION}"
                echo "Target environment: ${params.ENVIRONMENT}"
            }
        }
    }
}
```

### **Environment Variable Errors**
```groovy
// ❌ Incorrect - Wrong environment syntax
pipeline {
    agent any
    environment {
        PATH = "${PATH}:/usr/local/bin"  // Circular reference
        JAVA_HOME = /usr/lib/jvm/java-11  // Missing quotes
    }
    stages {
        stage('Build') {
            steps {
                echo "Java home: ${JAVA_HOME}"
            }
        }
    }
}

// ✅ Correct - Proper environment syntax
pipeline {
    agent any
    environment {
        PATH = "${env.PATH}:/usr/local/bin"
        JAVA_HOME = "/usr/lib/jvm/java-11"
    }
    stages {
        stage('Build') {
            steps {
                echo "Java home: ${env.JAVA_HOME}"
            }
        }
    }
}
```

## 🔍 Validation and Debugging

### **Syntax Validation Script**
```groovy
// validate-jenkinsfile.groovy
@Library('jenkins-shared-library') _

def validateJenkinsfile(String jenkinsfileContent) {
    try {
        // Parse the Jenkinsfile
        def pipeline = new org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition(jenkinsfileContent, true)
        
        // Validate syntax
        pipeline.create()
        
        return [valid: true, message: "Syntax is valid"]
    } catch (Exception e) {
        return [valid: false, message: e.getMessage()]
    }
}

// Usage in pipeline
pipeline {
    agent any
    stages {
        stage('Validate Syntax') {
            steps {
                script {
                    def jenkinsfile = readFile('Jenkinsfile')
                    def result = validateJenkinsfile(jenkinsfile)
                    
                    if (!result.valid) {
                        error("Jenkinsfile syntax error: ${result.message}")
                    }
                    
                    echo "Jenkinsfile syntax is valid"
                }
            }
        }
    }
}
```

### **Common Error Patterns**
```bash
# Search for common syntax errors in logs
grep -E "(SyntaxError|ParseException|unexpected token)" /var/log/jenkins/jenkins.log

# Check for specific patterns
grep -E "(Missing.*brace|Unexpected.*token|Invalid.*syntax)" build.log
```

### **Debugging Tools**
```groovy
// Debug pipeline execution
pipeline {
    agent any
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
    stages {
        stage('Debug') {
            steps {
                script {
                    // Print all environment variables
                    sh 'printenv | sort'
                    
                    // Print pipeline context
                    echo "Build number: ${env.BUILD_NUMBER}"
                    echo "Job name: ${env.JOB_NAME}"
                    echo "Workspace: ${env.WORKSPACE}"
                    
                    // Print parameters
                    params.each { key, value ->
                        echo "Parameter ${key}: ${value}"
                    }
                }
            }
        }
    }
}
```

## 🛠️ Quick Fixes

### **Syntax Checker Function**
```groovy
def checkSyntax() {
    try {
        // Your pipeline code here
        return true
    } catch (Exception e) {
        echo "Syntax error: ${e.getMessage()}"
        return false
    }
}

// Use in pipeline
if (!checkSyntax()) {
    error("Pipeline syntax validation failed")
}
```

### **Template Validation**
```groovy
// Pipeline template with validation
def validatePipelineTemplate(Map config) {
    def required = ['agent', 'stages']
    def missing = required.findAll { !config.containsKey(it) }
    
    if (missing) {
        error("Missing required sections: ${missing.join(', ')}")
    }
    
    if (!config.stages || config.stages.isEmpty()) {
        error("At least one stage is required")
    }
    
    return true
}

// Usage
def pipelineConfig = [
    agent: 'any',
    stages: [
        [name: 'Build', steps: ['echo "Building..."']]
    ]
]

validatePipelineTemplate(pipelineConfig)
```

### **Error Recovery Patterns**
```groovy
pipeline {
    agent any
    stages {
        stage('Build with Error Handling') {
            steps {
                script {
                    try {
                        // Potentially failing code
                        sh 'make build'
                    } catch (Exception e) {
                        echo "Build failed: ${e.getMessage()}"
                        
                        // Attempt recovery
                        sh 'make clean && make build'
                    }
                }
            }
        }
    }
}
```

## 📋 Syntax Error Prevention

### **Pre-commit Validation**
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Validate Jenkinsfile syntax before commit
if [ -f "Jenkinsfile" ]; then
    echo "Validating Jenkinsfile syntax..."
    
    # Use Jenkins CLI to validate
    java -jar jenkins-cli.jar -s http://jenkins:8080 \
        declarative-linter < Jenkinsfile
    
    if [ $? -ne 0 ]; then
        echo "Jenkinsfile syntax validation failed!"
        exit 1
    fi
    
    echo "Jenkinsfile syntax is valid"
fi
```

### **IDE Integration**
```json
// VS Code settings.json for Jenkins
{
    "jenkins.pipeline.linter.connector.url": "http://jenkins:8080/pipeline-model-converter/validate",
    "jenkins.pipeline.linter.connector.user": "admin",
    "jenkins.pipeline.linter.connector.pass": "token"
}
```

### **Shared Library Validation**
```groovy
// vars/validatePipeline.groovy
def call(Map config) {
    // Validate required fields
    assert config.containsKey('stages'), "stages section is required"
    assert config.stages instanceof List, "stages must be a list"
    
    // Validate each stage
    config.stages.each { stage ->
        assert stage.containsKey('name'), "stage name is required"
        assert stage.containsKey('steps'), "stage steps are required"
    }
    
    echo "Pipeline configuration is valid"
    return true
}
```

## 📊 Error Monitoring

### **Syntax Error Dashboard**
```groovy
// Monitor syntax errors across jobs
def getSyntaxErrors() {
    def errors = []
    
    Jenkins.instance.getAllItems(WorkflowJob.class).each { job ->
        def lastBuild = job.getLastBuild()
        if (lastBuild && lastBuild.getResult() == Result.FAILURE) {
            def log = lastBuild.getLog(100)
            if (log.any { it.contains('SyntaxError') || it.contains('ParseException') }) {
                errors.add([
                    job: job.fullName,
                    build: lastBuild.number,
                    timestamp: lastBuild.getTimestamp()
                ])
            }
        }
    }
    
    return errors
}

def errors = getSyntaxErrors()
errors.each { error ->
    println "Syntax error in ${error.job} build #${error.build}"
}
```

### **Automated Error Reporting**
```groovy
pipeline {
    agent any
    triggers {
        cron('0 9 * * MON')  // Weekly report
    }
    stages {
        stage('Generate Syntax Error Report') {
            steps {
                script {
                    def errors = getSyntaxErrors()
                    
                    if (errors) {
                        def report = "Syntax errors found in the following jobs:\n"
                        errors.each { error ->
                            report += "- ${error.job} (build #${error.build})\n"
                        }
                        
                        emailext (
                            subject: "Weekly Jenkins Syntax Error Report",
                            body: report,
                            to: "devops@company.com"
                        )
                    }
                }
            }
        }
    }
}
```

## 📋 Troubleshooting Checklist

### **Syntax Validation**
- [ ] Check bracket and brace matching
- [ ] Verify proper indentation
- [ ] Validate required sections (agent, stages)
- [ ] Check string quoting and escaping
- [ ] Verify parameter and variable syntax

### **Common Fixes**
- [ ] Use IDE with Jenkins syntax highlighting
- [ ] Enable pre-commit validation hooks
- [ ] Use shared libraries for common patterns
- [ ] Implement syntax checking in CI/CD
- [ ] Regular syntax error monitoring