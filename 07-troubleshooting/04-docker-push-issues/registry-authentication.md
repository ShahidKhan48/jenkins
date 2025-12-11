# Docker Registry Authentication Issues

## 🐳 Docker Registry Authentication Overview

Docker registry authentication problems prevent image pushes and pulls, disrupting CI/CD workflows.

## 🚨 Common Authentication Errors

### **Login Failures**
```
Error response from daemon: Get https://registry.company.com/v2/: unauthorized
denied: requested access to the resource is denied
Error response from daemon: login attempt to https://index.docker.io/v1/ failed with status: 401 Unauthorized
```

### **Push/Pull Failures**
```
denied: requested access to the resource is denied
unauthorized: authentication required
Error response from daemon: pull access denied for image, repository does not exist or may require 'docker login'
```

## 🔐 Docker Hub Authentication

### **Docker Hub Login**
```bash
# Manual login
docker login

# Login with credentials
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Login to specific registry
docker login registry.company.com -u username -p password
```

### **Jenkins Docker Hub Configuration**
```groovy
pipeline {
    agent any
    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_REPOSITORY = 'company/app'
    }
    stages {
        stage('Docker Build & Push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        def image = docker.build("${DOCKER_REPOSITORY}:${BUILD_NUMBER}")
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
    }
}
```

### **Docker Hub Credential Setup**
```groovy
// Create Docker Hub credential
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.domains.*

def store = SystemCredentialsProvider.getInstance().getStore()
def domain = Domain.global()

def dockerHubCred = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    "docker-hub-credentials",
    "Docker Hub Login",
    "your-username",
    "your-password-or-token"
)

store.addCredentials(domain, dockerHubCred)
```

## 🏢 Private Registry Authentication

### **Private Registry Setup**
```bash
# Create registry auth directory
mkdir -p /etc/docker/certs.d/registry.company.com

# Add CA certificate
cp company-ca.crt /etc/docker/certs.d/registry.company.com/ca.crt

# Configure insecure registry (if needed)
echo '{"insecure-registries": ["registry.company.com:5000"]}' > /etc/docker/daemon.json
systemctl restart docker
```

### **Harbor Registry Authentication**
```groovy
pipeline {
    agent any
    environment {
        HARBOR_REGISTRY = 'harbor.company.com'
        HARBOR_PROJECT = 'my-project'
    }
    stages {
        stage('Harbor Push') {
            steps {
                script {
                    docker.withRegistry("https://${HARBOR_REGISTRY}", 'harbor-credentials') {
                        def image = docker.build("${HARBOR_REGISTRY}/${HARBOR_PROJECT}/app:${BUILD_NUMBER}")
                        image.push()
                    }
                }
            }
        }
    }
}
```

### **Nexus Registry Configuration**
```bash
# Nexus Docker registry configuration
cat > /etc/docker/daemon.json << EOF
{
    "insecure-registries": ["nexus.company.com:8082"],
    "registry-mirrors": ["https://nexus.company.com:8082"]
}
EOF

systemctl restart docker
```

## ☁️ Cloud Registry Authentication

### **AWS ECR Authentication**
```groovy
pipeline {
    agent any
    environment {
        AWS_REGION = 'us-west-2'
        ECR_REGISTRY = '123456789012.dkr.ecr.us-west-2.amazonaws.com'
        ECR_REPOSITORY = 'my-app'
    }
    stages {
        stage('ECR Push') {
            steps {
                script {
                    // Get ECR login token
                    def loginCommand = sh(
                        script: "aws ecr get-login-password --region ${AWS_REGION}",
                        returnStdout: true
                    ).trim()
                    
                    // Login to ECR
                    sh "echo '${loginCommand}' | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                    
                    // Build and push
                    def image = docker.build("${ECR_REGISTRY}/${ECR_REPOSITORY}:${BUILD_NUMBER}")
                    image.push()
                }
            }
        }
    }
}
```

### **Google Container Registry (GCR)**
```groovy
pipeline {
    agent any
    environment {
        GCR_REGISTRY = 'gcr.io'
        GCP_PROJECT = 'my-gcp-project'
        IMAGE_NAME = 'my-app'
    }
    stages {
        stage('GCR Push') {
            steps {
                script {
                    // Authenticate with service account
                    withCredentials([file(credentialsId: 'gcp-service-account', variable: 'GCP_KEY')]) {
                        sh 'gcloud auth activate-service-account --key-file=$GCP_KEY'
                        sh 'gcloud auth configure-docker'
                        
                        def image = docker.build("${GCR_REGISTRY}/${GCP_PROJECT}/${IMAGE_NAME}:${BUILD_NUMBER}")
                        image.push()
                    }
                }
            }
        }
    }
}
```

### **Azure Container Registry (ACR)**
```groovy
pipeline {
    agent any
    environment {
        ACR_REGISTRY = 'myregistry.azurecr.io'
        ACR_REPOSITORY = 'my-app'
    }
    stages {
        stage('ACR Push') {
            steps {
                script {
                    withCredentials([azureServicePrincipal('azure-sp-credentials')]) {
                        sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
                        sh "az acr login --name ${ACR_REGISTRY.split('\\.')[0]}"
                        
                        def image = docker.build("${ACR_REGISTRY}/${ACR_REPOSITORY}:${BUILD_NUMBER}")
                        image.push()
                    }
                }
            }
        }
    }
}
```

## 🔧 Credential Management

### **Docker Config File**
```bash
# Check Docker config
cat ~/.docker/config.json

# Example config.json
{
    "auths": {
        "https://index.docker.io/v1/": {
            "auth": "base64-encoded-username:password"
        },
        "registry.company.com": {
            "auth": "base64-encoded-username:password"
        }
    },
    "credsStore": "desktop"
}
```

### **Credential Helper Setup**
```bash
# Install credential helpers
# For AWS ECR
pip install awscli
aws configure

# For GCR
gcloud auth configure-docker

# For ACR
az acr login --name myregistry
```

### **Jenkins Credential Store**
```groovy
// Docker registry credential with token
def dockerToken = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    "docker-registry-token",
    "Docker Registry Token",
    Secret.fromString("dckr_pat_xxxxxxxxxxxxxxxxxxxx")
)

store.addCredentials(domain, dockerToken)
```

## 🔍 Debugging Authentication Issues

### **Docker Login Debug**
```bash
# Enable Docker debug logging
export DOCKER_CONFIG=/tmp/docker-debug
mkdir -p $DOCKER_CONFIG

# Debug login
docker --debug login registry.company.com

# Check authentication
docker system info | grep -A 10 "Registry"
```

### **Registry Connectivity Test**
```bash
# Test registry connectivity
curl -v https://registry.company.com/v2/

# Test with authentication
curl -u username:password https://registry.company.com/v2/_catalog

# Test specific repository
curl -u username:password https://registry.company.com/v2/my-app/tags/list
```

### **Jenkins Docker Debug**
```groovy
pipeline {
    agent any
    stages {
        stage('Debug Docker') {
            steps {
                script {
                    // Check Docker version
                    sh 'docker version'
                    
                    // Check Docker info
                    sh 'docker system info'
                    
                    // List Docker configs
                    sh 'ls -la ~/.docker/'
                    
                    // Test registry connectivity
                    sh 'curl -v https://registry.company.com/v2/'
                }
            }
        }
    }
}
```

## 🛠️ Common Fixes

### **Clear Docker Credentials**
```bash
# Remove stored credentials
rm ~/.docker/config.json

# Logout from all registries
docker logout

# Re-login
docker login registry.company.com
```

### **Fix Permission Issues**
```bash
# Fix Docker socket permissions
sudo chmod 666 /var/run/docker.sock

# Add user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Fix credential file permissions
chmod 600 ~/.docker/config.json
```

### **Registry Certificate Issues**
```bash
# Add registry certificate
sudo mkdir -p /etc/docker/certs.d/registry.company.com
sudo cp registry.crt /etc/docker/certs.d/registry.company.com/ca.crt

# Or configure insecure registry
echo '{"insecure-registries": ["registry.company.com"]}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
```

## 🔐 Security Best Practices

### **Token-Based Authentication**
```bash
# Use personal access tokens instead of passwords
# Docker Hub: Account Settings → Security → New Access Token
# Harbor: User Profile → User Token
# Nexus: Security → Users → Generate Token
```

### **Credential Rotation**
```groovy
// Automated credential rotation
pipeline {
    agent any
    triggers {
        cron('0 2 1 * *')  // Monthly rotation
    }
    stages {
        stage('Rotate Docker Credentials') {
            steps {
                script {
                    // Generate new token via API
                    def newToken = generateNewDockerToken()
                    
                    // Update Jenkins credential
                    updateJenkinsCredential('docker-hub-credentials', newToken)
                    
                    // Test new credential
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        sh 'docker pull hello-world'
                    }
                }
            }
        }
    }
}
```

### **Least Privilege Access**
```yaml
# Harbor project member permissions
# Developer: push/pull images
# Guest: pull images only
# Master: full project access

# Nexus repository privileges
# nx-repository-view-docker-*-read
# nx-repository-view-docker-*-browse
# nx-repository-view-docker-*-add
```

## 📊 Monitoring Registry Authentication

### **Authentication Metrics**
```groovy
// Monitor Docker authentication failures
def checkDockerAuthFailures() {
    def failures = []
    
    Jenkins.instance.getAllItems(Job.class).each { job ->
        def lastBuild = job.getLastBuild()
        if (lastBuild) {
            def log = lastBuild.getLog(100)
            if (log.any { it.contains('unauthorized') || it.contains('authentication required') }) {
                failures.add([
                    job: job.fullName,
                    build: lastBuild.number,
                    timestamp: lastBuild.getTimestamp()
                ])
            }
        }
    }
    
    return failures
}

def failures = checkDockerAuthFailures()
if (failures) {
    println "Docker authentication failures detected:"
    failures.each { failure ->
        println "- ${failure.job} build #${failure.build}"
    }
}
```

### **Registry Health Check**
```bash
#!/bin/bash
# registry-health-check.sh

REGISTRIES=(
    "docker.io"
    "registry.company.com"
    "harbor.company.com"
)

for registry in "${REGISTRIES[@]}"; do
    echo "Checking $registry..."
    
    if curl -s -f "https://$registry/v2/" > /dev/null; then
        echo "✓ $registry is accessible"
    else
        echo "✗ $registry is not accessible"
    fi
    
    # Test authentication
    if docker login "$registry" --username "$DOCKER_USER" --password "$DOCKER_PASS" 2>/dev/null; then
        echo "✓ Authentication successful for $registry"
        docker logout "$registry"
    else
        echo "✗ Authentication failed for $registry"
    fi
done
```

## 📋 Troubleshooting Checklist

### **Authentication Setup**
- [ ] Valid credentials configured
- [ ] Correct registry URL
- [ ] Proper credential format
- [ ] Token permissions sufficient
- [ ] Certificate issues resolved

### **Network Connectivity**
- [ ] Registry accessible from Jenkins
- [ ] Firewall allows Docker traffic
- [ ] Proxy configuration correct
- [ ] DNS resolution working
- [ ] SSL/TLS certificates valid

### **Jenkins Configuration**
- [ ] Docker plugin installed
- [ ] Credentials stored correctly
- [ ] Pipeline syntax correct
- [ ] Agent has Docker access
- [ ] Proper error handling implemented