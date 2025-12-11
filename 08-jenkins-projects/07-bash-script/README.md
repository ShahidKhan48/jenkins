# Bash Script Library

## 📋 Script Collection

Reusable bash scripts for Jenkins pipelines and CI/CD automation.

## 🔧 Available Scripts

### **build-and-push.sh**
```bash
# Build and push Docker images
./build-and-push.sh <image-name> <tag> [dockerfile]

# Examples
./build-and-push.sh myapp v1.0.0
./build-and-push.sh api latest Dockerfile.prod
```

### **test-runner.sh**
```bash
# Run tests for different project types
./test-runner.sh <test-type> <project-type>

# Examples
./test-runner.sh unit java
./test-runner.sh integration nodejs
./test-runner.sh security python
```

### **Legacy Scripts**
- **1-build-and-push-images.sh** - Original comprehensive build script
- **check-changes.sh** - Git change detection
- **cleanup.sh** - Workspace and artifact cleanup
- **deploy-docker.sh** - Docker deployment automation
- **deploy-k8s.sh** - Kubernetes deployment
- **terraform-apply.sh** - Terraform apply automation
- **terraform-plan.sh** - Terraform plan execution

## 🚀 Usage in Pipelines

### **Java Pipeline Integration**
```groovy
stage('Test') {
    steps {
        sh "chmod +x scripts/test-runner.sh"
        sh "scripts/test-runner.sh unit java"
    }
}

stage('Build & Push') {
    steps {
        sh "chmod +x scripts/build-and-push.sh"
        sh "scripts/build-and-push.sh myapp ${BUILD_NUMBER}"
    }
}
```

### **Node.js Pipeline Integration**
```groovy
stage('Security Tests') {
    steps {
        sh "chmod +x scripts/test-runner.sh"
        sh "scripts/test-runner.sh security nodejs"
    }
}
```

### **Python Pipeline Integration**
```groovy
stage('Integration Tests') {
    steps {
        sh '''
            . venv/bin/activate
            chmod +x scripts/test-runner.sh
            scripts/test-runner.sh integration python
        '''
    }
}
```

## 📝 Environment Variables

### **Docker Registry Configuration**
```bash
export DOCKER_REGISTRY="harbor.company.com"
export DOCKER_NAMESPACE="myteam"
```

### **Test Configuration**
```bash
export TEST_TIMEOUT="300"
export COVERAGE_THRESHOLD="80"
```

## 🔐 Security Features

- Vulnerability scanning with Trivy
- Security test automation
- Credential handling best practices
- Error handling and logging