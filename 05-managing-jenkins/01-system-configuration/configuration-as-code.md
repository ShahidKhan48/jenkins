# Configuration as Code (JCasC)

## 🎯 What is JCasC?

Jenkins Configuration as Code (JCasC) allows you to define Jenkins configuration in YAML files, enabling version control, reproducibility, and automation of Jenkins setup.

## 📝 Basic JCasC Structure

```yaml
jenkins:
  systemMessage: "Jenkins configured automatically by JCasC"
  numExecutors: 2
  mode: NORMAL
  
credentials:
  system:
    domainCredentials:
      - credentials: []

unclassified:
  location:
    url: "http://jenkins.company.com:8080/"
    adminAddress: "admin@company.com"
```

## 🔧 Jenkins Core Configuration

### **System Settings**
```yaml
jenkins:
  systemMessage: |
    This Jenkins instance is managed by Configuration as Code.
    Changes made through the UI will be overwritten.
  
  numExecutors: 0  # Don't run builds on master
  mode: EXCLUSIVE  # Only run jobs tied to master
  
  quietPeriod: 5
  scmCheckoutRetryCount: 3
  
  globalNodeProperties:
    - envVars:
        env:
          - key: "JAVA_HOME"
            value: "/usr/lib/jvm/java-11-openjdk"
          - key: "MAVEN_HOME"
            value: "/opt/maven"
          - key: "PATH"
            value: "/opt/maven/bin:/usr/local/bin:${PATH}"
```

### **Security Configuration**
```yaml
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "admin"
          password: "${ADMIN_PASSWORD}"
        - id: "developer"
          password: "${DEV_PASSWORD}"
  
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"
        - "Job/Build:developer"
        - "Job/Read:developer"
        - "Job/Workspace:developer"
  
  remotingSecurity:
    enabled: true
```

### **Agent Configuration**
```yaml
jenkins:
  nodes:
    - permanent:
        name: "linux-agent-1"
        remoteFS: "/home/jenkins"
        labelString: "linux docker maven"
        mode: NORMAL
        numExecutors: 4
        launcher:
          ssh:
            host: "agent1.company.com"
            port: 22
            credentialsId: "ssh-agent-key"
            launchTimeoutSeconds: 60
            maxNumRetries: 3
```

## 🔐 Credentials Management

### **Various Credential Types**
```yaml
credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              scope: GLOBAL
              id: "database-credentials"
              username: "dbuser"
              password: "${DATABASE_PASSWORD}"
              description: "Database connection credentials"
          
          - string:
              scope: GLOBAL
              id: "api-token"
              secret: "${API_TOKEN}"
              description: "External API token"
          
          - basicSSHUserPrivateKey:
              scope: GLOBAL
              id: "ssh-agent-key"
              username: "jenkins"
              privateKeySource:
                directEntry:
                  privateKey: "${SSH_PRIVATE_KEY}"
              description: "SSH key for agents"
          
          - certificate:
              scope: GLOBAL
              id: "ssl-certificate"
              password: "${CERT_PASSWORD}"
              keyStoreSource:
                fileOnMaster:
                  keyStoreFile: "/var/jenkins_home/certs/keystore.p12"
```

## 🛠️ Tool Configuration

### **Global Tools**
```yaml
tool:
  git:
    installations:
      - name: "Default"
        home: "/usr/bin/git"
  
  maven:
    installations:
      - name: "Maven-3.8.1"
        properties:
          - installSource:
              installers:
                - maven:
                    id: "3.8.1"
  
  jdk:
    installations:
      - name: "JDK-11"
        home: "/usr/lib/jvm/java-11-openjdk"
      - name: "JDK-17"
        properties:
          - installSource:
              installers:
                - adoptOpenJdkInstaller:
                    id: "jdk-17.0.1+12"
  
  nodejs:
    installations:
      - name: "NodeJS-16"
        properties:
          - installSource:
              installers:
                - nodeJSInstaller:
                    id: "16.14.0"
                    npmPackages: "yarn@1.22.17"
```

## 📧 Notification Configuration

### **Email Setup**
```yaml
unclassified:
  mailer:
    smtpHost: "smtp.gmail.com"
    smtpPort: 587
    useSsl: false
    useTls: true
    charset: "UTF-8"
    authentication:
      username: "jenkins@company.com"
      password: "${SMTP_PASSWORD}"
    defaultSuffix: "@company.com"
  
  location:
    url: "https://jenkins.company.com/"
    adminAddress: "Jenkins Admin <admin@company.com>"
```

### **Slack Integration**
```yaml
unclassified:
  slackNotifier:
    baseUrl: "https://hooks.slack.com/services/"
    teamDomain: "company"
    token: "${SLACK_TOKEN}"
    room: "#jenkins"
    sendAs: "Jenkins"
```

## 🔌 Plugin Configuration

### **Plugin Installation**
```yaml
jenkins:
  install:
    runSetupWizard: false
  
  plugins:
    required:
      - ant:latest
      - build-timeout:latest
      - credentials-binding:latest
      - email-ext:latest
      - git:latest
      - github-branch-source:latest
      - gradle:latest
      - ldap:latest
      - mailer:latest
      - matrix-auth:latest
      - pipeline-github-lib:latest
      - pipeline-stage-view:latest
      - ssh-slaves:latest
      - timestamper:latest
      - workflow-aggregator:latest
      - ws-cleanup:latest
```

### **Plugin-specific Configuration**
```yaml
unclassified:
  gitHubPluginConfig:
    configs:
      - name: "GitHub"
        apiUrl: "https://api.github.com"
        credentialsId: "github-token"
        manageHooks: true
  
  githubPullRequests:
    actualiseOnFactory: true
  
  buildDiscarders:
    configuredBuildDiscarders:
      - "jobBuildDiscarder"
      - simpleBuildDiscarder:
          discarder:
            logRotator:
              daysToKeepStr: "30"
              numToKeepStr: "100"
```

## 🏗️ Job DSL Integration

### **Seed Job Configuration**
```yaml
jobs:
  - script: |
      folder('Applications') {
          description('Application build jobs')
      }
      
      multibranchPipelineJob('Applications/my-app') {
          branchSources {
              github {
                  id('my-app-github')
                  scanCredentialsId('github-token')
                  repoOwner('company')
                  repository('my-app')
              }
          }
          orphanedItemStrategy {
              discardOldItems {
                  daysToKeep(7)
              }
          }
      }
```

## 🔄 Environment-specific Configuration

### **Development Environment**
```yaml
# jenkins-dev.yaml
jenkins:
  systemMessage: "Development Jenkins Instance"
  numExecutors: 2
  
  globalNodeProperties:
    - envVars:
        env:
          - key: "ENVIRONMENT"
            value: "development"
          - key: "LOG_LEVEL"
            value: "DEBUG"

unclassified:
  location:
    url: "https://jenkins-dev.company.com/"
```

### **Production Environment**
```yaml
# jenkins-prod.yaml
jenkins:
  systemMessage: "Production Jenkins Instance"
  numExecutors: 0  # No builds on master
  
  globalNodeProperties:
    - envVars:
        env:
          - key: "ENVIRONMENT"
            value: "production"
          - key: "LOG_LEVEL"
            value: "INFO"

unclassified:
  location:
    url: "https://jenkins.company.com/"
```

## 📦 Docker Integration

### **Docker Configuration**
```yaml
unclassified:
  dockerBuilder:
    dockerInstallations:
      - name: "docker"
        home: "/usr/bin/docker"
  
  docker-plugin:
    dockerClouds:
      - name: "docker-cloud"
        dockerApi:
          dockerHost:
            uri: "unix:///var/run/docker.sock"
        templates:
          - labelString: "docker-agent"
            dockerTemplateBase:
              image: "jenkins/inbound-agent:latest"
              pullCredentialsId: "docker-registry"
            remoteFs: "/home/jenkins"
            connector:
              attach:
                user: "jenkins"
            instanceCapStr: "10"
```

## ☸️ Kubernetes Integration

### **Kubernetes Cloud**
```yaml
jenkins:
  clouds:
    - kubernetes:
        name: "kubernetes"
        serverUrl: "https://kubernetes.company.com"
        namespace: "jenkins"
        credentialsId: "k8s-service-account"
        jenkinsUrl: "http://jenkins.jenkins.svc.cluster.local:8080"
        jenkinsTunnel: "jenkins-agent.jenkins.svc.cluster.local:50000"
        containerCapStr: "100"
        maxRequestsPerHostStr: "32"
        retentionTimeout: 5
        connectTimeout: 10
        readTimeout: 20
        
        templates:
          - name: "maven-agent"
            label: "maven"
            nodeUsageMode: EXCLUSIVE
            containers:
              - name: "maven"
                image: "maven:3.8.1-openjdk-11"
                command: "sleep"
                args: "infinity"
                workingDir: "/home/jenkins/agent"
                resourceRequestMemory: "1Gi"
                resourceLimitMemory: "2Gi"
                resourceRequestCpu: "500m"
                resourceLimitCpu: "1000m"
```

## 🔧 Advanced Configuration

### **Script Security**
```yaml
security:
  scriptApproval:
    approvedSignatures:
      - "method java.lang.String toLowerCase"
      - "method java.util.Properties getProperty java.lang.String"
      - "staticMethod java.lang.System getProperty java.lang.String"
```

### **Global Libraries**
```yaml
unclassified:
  globalLibraries:
    libraries:
      - name: "shared-pipeline-library"
        defaultVersion: "main"
        retriever:
          modernSCM:
            scm:
              git:
                remote: "https://github.com/company/jenkins-shared-library.git"
                credentialsId: "github-token"
        implicit: true
        allowVersionOverride: true
```

## 🚀 Deployment Strategies

### **Environment Variables**
```bash
# Set environment variables for secrets
export ADMIN_PASSWORD="secure-admin-password"
export DATABASE_PASSWORD="db-password"
export API_TOKEN="api-token-value"
export SMTP_PASSWORD="smtp-password"
export SLACK_TOKEN="slack-token"
export SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"

# Start Jenkins with JCasC
export CASC_JENKINS_CONFIG=/var/jenkins_home/casc.yaml
java -jar jenkins.war
```

### **Docker Deployment**
```dockerfile
FROM jenkins/jenkins:lts

# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copy JCasC configuration
COPY jenkins.yaml /var/jenkins_home/casc_configs/jenkins.yaml

# Set JCasC environment variable
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs
```

### **Kubernetes Deployment**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: jenkins-casc-config
data:
  jenkins.yaml: |
    jenkins:
      systemMessage: "Kubernetes Jenkins Instance"
      # ... rest of configuration

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
spec:
  template:
    spec:
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        env:
        - name: CASC_JENKINS_CONFIG
          value: /var/jenkins_home/casc_configs
        volumeMounts:
        - name: casc-config
          mountPath: /var/jenkins_home/casc_configs
      volumes:
      - name: casc-config
        configMap:
          name: jenkins-casc-config
```

## 🔍 Validation and Testing

### **Configuration Validation**
```bash
# Validate YAML syntax
yamllint jenkins.yaml

# Test configuration with Jenkins
java -jar jenkins-cli.jar -s http://localhost:8080/ \
  reload-jcasc-configuration
```

### **Configuration Export**
```bash
# Export current configuration
java -jar jenkins-cli.jar -s http://localhost:8080/ \
  export-configuration > current-config.yaml
```

## 💡 Best Practices

### **1. Use Environment Variables for Secrets**
```yaml
credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              id: "database"
              username: "dbuser"
              password: "${DATABASE_PASSWORD}"  # From environment
```

### **2. Version Control Configuration**
```bash
# Store in Git repository
git add jenkins.yaml
git commit -m "Update Jenkins configuration"
git push origin main
```

### **3. Environment-specific Configurations**
```bash
# Use different files per environment
CASC_JENKINS_CONFIG=/configs/jenkins-${ENVIRONMENT}.yaml
```

### **4. Gradual Migration**
```yaml
# Start with basic configuration
jenkins:
  systemMessage: "Migrating to JCasC"
  
# Add sections incrementally
# - Security
# - Tools
# - Plugins
# - Jobs
```