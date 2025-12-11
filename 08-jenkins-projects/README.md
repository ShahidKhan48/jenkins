# Jenkins Projects & Examples

## 📋 Project Collection Overview

This section provides comprehensive, production-ready Jenkins pipeline examples for various technology stacks and deployment scenarios.

## 📚 Learning Path

### **🔰 Beginner Level**
1. **Java Project** → Maven builds, testing, and Docker deployment
2. **Node.js Project** → npm workflows and container deployment
3. **Python Project** → pip packages, testing, and cloud deployment

### **🔥 Intermediate Level**
4. **Terraform Pipeline** → Infrastructure as Code with security scanning
5. **Kubernetes Deployment** → Container orchestration and deployment strategies
6. **Ansible Project** → Configuration management and automation

### **🚀 Advanced Level**
7. **Script Library** → Reusable automation scripts and utilities
8. **Shared CI Templates** → Enterprise-grade pipeline templates

## 🎯 Quick Start Guide

### **Choose Your Technology Stack**
```bash
# Java/Spring Boot Application
cd 01-java-project/
jenkins-cli create-job java-microservice < job-config.xml

# Node.js/React Application  
cd 02-nodejs-project/
jenkins-cli create-job nodejs-webapp < job-config.xml

# Python/FastAPI Application
cd 03-python-project/
jenkins-cli create-job python-api < job-config.xml
```

### **Infrastructure & Deployment**
```bash
# Terraform Infrastructure
cd 04-terraform-pipeline/
jenkins-cli create-job terraform-aws < job-config.xml

# Kubernetes Deployment
cd 05-kubernetes-deployment/
jenkins-cli create-job k8s-deploy < job-config.xml
```

## 📖 Project Contents

### **01. Java Project**
- **[Jenkinsfile](01-java-project/Jenkinsfile)** → Complete Maven pipeline with testing, security scanning, and Docker deployment
- **[Dockerfile](01-java-project/Dockerfile)** → Optimized Java container image
- **Features**: Maven builds, JUnit testing, SonarQube analysis, OWASP dependency check, Docker registry push

### **02. Node.js Project**
- **[Jenkinsfile](02-nodejs-project/Jenkinsfile)** → npm-based pipeline with comprehensive testing
- **Features**: npm/yarn builds, ESLint, Prettier, Jest testing, Cypress E2E, security audits

### **03. Python Project**
- **[Jenkinsfile](03-python-project/Jenkinsfile)** → Python application with testing and GCP deployment
- **Features**: pip/poetry, pytest, flake8, mypy, bandit security, performance testing

### **04. Terraform Pipeline**
- **[Jenkinsfile](04-terraform-pipeline/Jenkinsfile)** → Infrastructure as Code with approval workflows
- **Features**: Terraform plan/apply, security scanning, cost estimation, compliance checks

### **05. Kubernetes Deployment**
- **[Jenkinsfile](05-kubernetes-deployment/Jenkinsfile)** → Advanced K8s deployment strategies
- **Features**: Helm charts, blue-green deployment, canary releases, security scanning

### **06. Ansible Project**
- **Configuration Management** → Automated server configuration and application deployment
- **Features**: Playbook execution, inventory management, vault secrets, compliance

### **07. Script Library**
- **[Build & Push Images](07-script-library/1-build-and-push-images.sh)** → Docker image automation
- **Utility Scripts** → Common automation tasks and helper functions

### **08. Shared CI Templates**
- **Pipeline Templates** → Reusable pipeline patterns for enterprise use
- **Job DSL Scripts** → Automated job creation and management

## 🏗️ Architecture Patterns

### **Microservices Pipeline**
```groovy
// Multi-service build and deployment
pipeline {
    agent none
    
    stages {
        stage('Build Services') {
            parallel {
                stage('User Service') {
                    agent any
                    steps {
                        build job: 'user-service-build'
                    }
                }
                stage('Order Service') {
                    agent any
                    steps {
                        build job: 'order-service-build'
                    }
                }
                stage('Payment Service') {
                    agent any
                    steps {
                        build job: 'payment-service-build'
                    }
                }
            }
        }
        
        stage('Integration Tests') {
            agent any
            steps {
                build job: 'integration-test-suite'
            }
        }
        
        stage('Deploy to Staging') {
            agent any
            steps {
                build job: 'deploy-microservices',
                    parameters: [
                        string(name: 'ENVIRONMENT', value: 'staging')
                    ]
            }
        }
    }
}
```

### **GitOps Workflow**
```groovy
// GitOps deployment pattern
pipeline {
    agent any
    
    stages {
        stage('Update Manifests') {
            steps {
                script {
                    // Update Kubernetes manifests in GitOps repo
                    sh '''
                        git clone https://github.com/company/k8s-manifests.git
                        cd k8s-manifests
                        
                        # Update image tags
                        sed -i "s|image: app:.*|image: app:${BUILD_NUMBER}|g" apps/*/deployment.yaml
                        
                        git add .
                        git commit -m "Update app to version ${BUILD_NUMBER}"
                        git push origin main
                    '''
                }
            }
        }
        
        stage('Wait for ArgoCD Sync') {
            steps {
                script {
                    // Wait for ArgoCD to sync changes
                    timeout(time: 10, unit: 'MINUTES') {
                        waitUntil {
                            script {
                                def result = sh(
                                    script: 'argocd app get myapp --output json | jq -r .status.sync.status',
                                    returnStdout: true
                                ).trim()
                                return result == 'Synced'
                            }
                        }
                    }
                }
            }
        }
    }
}
```

## 🔧 Common Pipeline Patterns

### **Multi-Environment Deployment**
```groovy
def deployToEnvironment(environment) {
    return {
        stage("Deploy to ${environment}") {
            when {
                anyOf {
                    branch 'main'
                    expression { params.FORCE_DEPLOY }
                }
            }
            steps {
                script {
                    def approvalRequired = environment == 'prod'
                    
                    if (approvalRequired) {
                        input(
                            message: "Deploy to ${environment}?",
                            ok: "Deploy",
                            submitter: "devops-leads"
                        )
                    }
                    
                    // Deployment logic
                    sh """
                        helm upgrade --install myapp ./helm-chart \\
                            --namespace ${environment} \\
                            --values values-${environment}.yaml \\
                            --set image.tag=${BUILD_NUMBER}
                    """
                }
            }
        }
    }
}

// Usage in pipeline
stages {
    stage('Deploy') {
        parallel {
            'dev': deployToEnvironment('dev'),
            'staging': deployToEnvironment('staging'),
            'prod': deployToEnvironment('prod')
        }
    }
}
```

### **Feature Branch Workflow**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Feature Branch Build') {
            when {
                not { 
                    anyOf {
                        branch 'main'
                        branch 'develop'
                    }
                }
            }
            steps {
                // Build and test feature branch
                sh 'make build test'
                
                // Deploy to ephemeral environment
                script {
                    def branchName = env.BRANCH_NAME.replaceAll(/[^a-zA-Z0-9]/, '-').toLowerCase()
                    def namespace = "feature-${branchName}"
                    
                    sh """
                        kubectl create namespace ${namespace} || true
                        helm upgrade --install ${branchName} ./helm-chart \\
                            --namespace ${namespace} \\
                            --set image.tag=${BUILD_NUMBER} \\
                            --set ingress.host=${branchName}.dev.company.com
                    """
                    
                    // Comment on PR with environment URL
                    if (env.CHANGE_ID) {
                        pullRequest.comment("🚀 Feature environment deployed: https://${branchName}.dev.company.com")
                    }
                }
            }
        }
    }
    
    post {
        cleanup {
            script {
                // Clean up feature environment when branch is deleted
                if (env.BRANCH_NAME != 'main' && env.BRANCH_NAME != 'develop') {
                    def branchName = env.BRANCH_NAME.replaceAll(/[^a-zA-Z0-9]/, '-').toLowerCase()
                    sh """
                        helm uninstall ${branchName} --namespace feature-${branchName} || true
                        kubectl delete namespace feature-${branchName} || true
                    """
                }
            }
        }
    }
}
```

## 📊 Monitoring & Observability

### **Pipeline Metrics Collection**
```groovy
// Collect build metrics
def collectMetrics() {
    script {
        def metrics = [
            buildNumber: env.BUILD_NUMBER,
            duration: currentBuild.duration,
            result: currentBuild.result,
            timestamp: System.currentTimeMillis(),
            branch: env.BRANCH_NAME,
            commit: env.GIT_COMMIT
        ]
        
        // Send to monitoring system
        httpRequest(
            httpMode: 'POST',
            url: 'https://metrics.company.com/jenkins/builds',
            contentType: 'APPLICATION_JSON',
            requestBody: groovy.json.JsonBuilder(metrics).toString()
        )
    }
}

// Usage in post section
post {
    always {
        collectMetrics()
    }
}
```

### **Performance Tracking**
```groovy
// Track deployment performance
def trackDeploymentTime() {
    script {
        def startTime = System.currentTimeMillis()
        
        // Deployment steps here
        
        def endTime = System.currentTimeMillis()
        def duration = (endTime - startTime) / 1000
        
        // Log performance metrics
        echo "Deployment completed in ${duration} seconds"
        
        // Alert if deployment takes too long
        if (duration > 300) { // 5 minutes
            slackSend(
                channel: '#alerts',
                color: 'warning',
                message: "⚠️ Slow deployment detected: ${duration}s for ${env.JOB_NAME}"
            )
        }
    }
}
```

## 🔐 Security Integration

### **Security Scanning Pipeline**
```groovy
stage('Security Scans') {
    parallel {
        stage('SAST') {
            steps {
                // Static Application Security Testing
                sh 'sonar-scanner -Dsonar.projectKey=myapp'
            }
        }
        stage('Dependency Check') {
            steps {
                // Check for vulnerable dependencies
                sh 'dependency-check --project myapp --scan .'
            }
        }
        stage('Container Scan') {
            steps {
                // Scan Docker image for vulnerabilities
                sh 'trivy image myapp:${BUILD_NUMBER}'
            }
        }
        stage('Infrastructure Scan') {
            steps {
                // Scan infrastructure as code
                sh 'checkov -d terraform/ --framework terraform'
            }
        }
    }
}
```

## 📋 Best Practices Checklist

### **Pipeline Design**
- [ ] Use declarative pipeline syntax
- [ ] Implement proper error handling
- [ ] Add comprehensive logging
- [ ] Use parallel stages where possible
- [ ] Implement proper cleanup in post sections

### **Security**
- [ ] Scan for vulnerabilities in all stages
- [ ] Use secure credential management
- [ ] Implement approval workflows for production
- [ ] Regular security updates and patches
- [ ] Audit trail for all deployments

### **Performance**
- [ ] Optimize build times with caching
- [ ] Use appropriate agent labels
- [ ] Implement build parallelization
- [ ] Monitor and alert on performance metrics
- [ ] Regular cleanup of old builds and artifacts

### **Reliability**
- [ ] Implement retry mechanisms
- [ ] Add health checks and smoke tests
- [ ] Use blue-green or canary deployments
- [ ] Implement rollback procedures
- [ ] Monitor deployment success rates

## 🚀 Advanced Features

### **Dynamic Pipeline Generation**
- Pipeline as Code with Job DSL
- Multi-branch pipeline configuration
- Shared library integration
- Template-based job creation

### **Integration Patterns**
- GitOps workflow implementation
- Multi-cloud deployment strategies
- Microservices orchestration
- Event-driven pipeline triggers

### **Compliance & Governance**
- Automated compliance checking
- Audit trail generation
- Policy as Code implementation
- Regulatory requirement validation

---

**Next Steps**: Choose a project template that matches your technology stack and customize it for your specific requirements. Each project includes comprehensive documentation and can be extended with additional features as needed.