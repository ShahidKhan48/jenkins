# Managing Nodes

## 🖥️ Node Management Overview

Jenkins nodes (also called agents) are machines that execute builds. Proper node management is crucial for scalable and efficient CI/CD operations.

## 📍 Accessing Node Management

**Navigate to:** Manage Jenkins → Manage Nodes and Clouds

## 🎯 Node Types

### **Master Node**
- Built-in node where Jenkins runs
- Should primarily handle coordination
- Avoid running builds on master in production

### **Permanent Agents**
- Dedicated machines for builds
- Always available (when online)
- Configured manually

### **Cloud Agents**
- Dynamically provisioned
- Created on-demand
- Automatically terminated after use

## ➕ Adding Permanent Agents

### **Step 1: Create New Node**
```
1. Click "New Node"
2. Node name: linux-agent-01
3. Type: Permanent Agent
4. Click "Create"
```

### **Step 2: Configure Node**
```
Name: linux-agent-01
Description: Linux build agent for Java projects
# of executors: 4
Remote root directory: /home/jenkins
Labels: linux java maven docker
Usage: Use this node as much as possible
Launch method: Launch agents via SSH
Host: 192.168.1.100
Credentials: jenkins-ssh-key
Host Key Verification Strategy: Known hosts file Verification Strategy
Availability: Keep this agent online as much as possible
```

### **Step 3: Node Properties**
```
Environment variables:
├── JAVA_HOME = /usr/lib/jvm/java-11-openjdk
├── MAVEN_HOME = /opt/maven
└── DOCKER_HOST = unix:///var/run/docker.sock

Tool Locations:
├── Git = /usr/bin/git
├── Maven = /opt/maven/bin/mvn
└── JDK = /usr/lib/jvm/java-11-openjdk
```

## 🔧 Launch Methods

### **SSH Launch**
```
Launch method: Launch agents via SSH
Host: agent.company.com
Credentials: [SSH Username with private key]
Host Key Verification Strategy: Known hosts file
Port: 22
JVM Options: -Xmx2g
Prefix Start Agent Command: sudo -u jenkins
Suffix Start Agent Command: &
Connection Timeout: 60
Maximum Number of Retries: 3
Seconds To Wait Between Retries: 15
```

### **JNLP Launch**
```
Launch method: Launch agent by connecting it to the master
Tunnel connection through: jenkins.company.com:50000
JVM Options: -Xmx1g -XX:+UseG1GC

# On agent machine:
java -jar agent.jar -jnlpUrl http://jenkins:8080/computer/agent1/jenkins-agent.jnlp -secret [secret] -workDir "/home/jenkins"
```

### **Windows Service**
```
Launch method: Let Jenkins control this Windows slave as a Windows service
Administrator username: DOMAIN\jenkins-admin
Password: [password]
Path to java: C:\Program Files\Java\jdk-11\bin\java.exe
JVM Options: -Xmx2g
```

## 🏷️ Node Labels and Usage

### **Label Strategy**
```
Operating System Labels:
├── linux
├── windows
├── macos

Architecture Labels:
├── x86_64
├── arm64

Tool Labels:
├── java
├── maven
├── nodejs
├── docker
├── kubernetes

Environment Labels:
├── production
├── staging
├── development

Capability Labels:
├── gpu
├── high-memory
├── ssd-storage
├── network-isolated
```

### **Usage Patterns**
```groovy
pipeline {
    agent {
        label 'linux && docker && maven'  // Multiple requirements
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
    }
}
```

### **Node-specific Stages**
```groovy
pipeline {
    agent none
    stages {
        stage('Linux Build') {
            agent {
                label 'linux'
            }
            steps {
                sh 'make build'
            }
        }
        stage('Windows Build') {
            agent {
                label 'windows'
            }
            steps {
                bat 'build.bat'
            }
        }
    }
}
```

## 📊 Node Monitoring

### **Node Status Dashboard**
```groovy
// Groovy script to check node status
import jenkins.model.*

def jenkins = Jenkins.getInstance()

println "Node Status Report"
println "=================="

jenkins.getNodes().each { node ->
    def computer = node.toComputer()
    def name = node.getNodeName()
    def labels = node.getLabelString()
    def executors = node.getNumExecutors()
    def online = computer.isOnline()
    def idle = computer.isIdle()
    def offline_reason = computer.getOfflineCause()
    
    println "Node: ${name}"
    println "  Labels: ${labels}"
    println "  Executors: ${executors}"
    println "  Online: ${online}"
    println "  Idle: ${idle}"
    if (!online && offline_reason) {
        println "  Offline Reason: ${offline_reason}"
    }
    println "  ---"
}
```

### **Node Utilization Metrics**
```groovy
// Monitor node utilization
import jenkins.model.*
import hudson.model.*

def jenkins = Jenkins.getInstance()

jenkins.getComputers().each { computer ->
    def node = computer.getNode()
    def name = computer.getName()
    def executors = computer.getExecutors()
    def busyExecutors = executors.findAll { it.isBusy() }
    def utilization = executors.size() > 0 ? (busyExecutors.size() / executors.size()) * 100 : 0
    
    println "Node: ${name}"
    println "  Total Executors: ${executors.size()}"
    println "  Busy Executors: ${busyExecutors.size()}"
    println "  Utilization: ${utilization.round(2)}%"
    
    // Show current builds
    busyExecutors.each { executor ->
        def currentBuild = executor.getCurrentExecutable()
        if (currentBuild) {
            println "    Running: ${currentBuild.getParent().getFullDisplayName()} #${currentBuild.getNumber()}"
        }
    }
    println "  ---"
}
```

## 🔧 Node Configuration Scripts

### **Automated Node Setup**
```bash
#!/bin/bash
# setup-jenkins-agent.sh

# Install Java
sudo apt update
sudo apt install -y openjdk-11-jdk

# Create jenkins user
sudo useradd -m -s /bin/bash jenkins
sudo mkdir -p /home/jenkins/.ssh
sudo chown jenkins:jenkins /home/jenkins/.ssh
sudo chmod 700 /home/jenkins/.ssh

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker jenkins

# Install Maven
wget https://archive.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz
sudo tar -xzf apache-maven-3.8.1-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.8.1 /opt/maven
sudo chown -R jenkins:jenkins /opt/maven

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Configure environment
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' | sudo tee -a /home/jenkins/.bashrc
echo 'export MAVEN_HOME=/opt/maven' | sudo tee -a /home/jenkins/.bashrc
echo 'export PATH=$MAVEN_HOME/bin:$PATH' | sudo tee -a /home/jenkins/.bashrc

# Set up SSH key (copy from master)
# sudo -u jenkins ssh-keygen -t rsa -b 4096 -f /home/jenkins/.ssh/id_rsa -N ""
```

### **Node Health Check Script**
```bash
#!/bin/bash
# node-health-check.sh

echo "=== Jenkins Agent Health Check ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime)"
echo ""

# Check disk space
echo "=== Disk Usage ==="
df -h | grep -E "(Filesystem|/dev/)"
echo ""

# Check memory
echo "=== Memory Usage ==="
free -h
echo ""

# Check Java
echo "=== Java Version ==="
java -version 2>&1
echo ""

# Check Docker
echo "=== Docker Status ==="
if command -v docker &> /dev/null; then
    docker --version
    docker system df
else
    echo "Docker not installed"
fi
echo ""

# Check Jenkins agent process
echo "=== Jenkins Agent Process ==="
ps aux | grep -E "(jenkins|agent)" | grep -v grep
echo ""

# Check network connectivity to master
echo "=== Network Connectivity ==="
JENKINS_MASTER=${JENKINS_MASTER:-"jenkins.company.com"}
ping -c 3 $JENKINS_MASTER
telnet $JENKINS_MASTER 8080 < /dev/null
```

## 🚀 Dynamic Node Provisioning

### **Docker Cloud Configuration**
```groovy
// Configure Docker cloud
import jenkins.model.*
import com.nirima.jenkins.plugins.docker.*

def jenkins = Jenkins.getInstance()

// Create Docker cloud
def dockerCloud = new DockerCloud(
    "docker-cloud",                    // name
    [                                  // templates
        new DockerTemplate(
            "jenkins/inbound-agent:latest",  // image
            "docker-agent",                  // labelString
            "/home/jenkins",                 // remoteFs
            "2",                            // instanceCapStr
            Node.Mode.NORMAL,               // mode
            "docker-agent",                 // retentionStrategy
            new DockerComputerAttachConnector(), // connector
            "1",                            // dockerCommand
            "jenkins",                      // volumesString
            "jenkins",                      // volumesFromString
            "",                             // environmentsString
            "",                             // hostname
            1024,                           // memoryLimit
            0,                              // memorySwap
            0,                              // cpuShares
            "",                             // bindPorts
            true,                           // bindAllPorts
            true,                           // privileged
            true,                           // tty
            "",                             // macAddress
            ""                              // extraHostsString
        )
    ],
    "unix:///var/run/docker.sock",    // serverUrl
    100,                               // containerCap
    10,                                // connectTimeout
    10,                                // readTimeout
    null,                              // credentialsId
    "",                                // version
    ""                                 // dockerHostname
)

jenkins.clouds.add(dockerCloud)
jenkins.save()
```

### **Kubernetes Cloud Configuration**
```yaml
# kubernetes-agent-template.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "1Gi"
        cpu: "1000m"
  - name: maven
    image: maven:3.8.1-openjdk-11
    command: ['cat']
    tty: true
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1000m"
  - name: docker
    image: docker:dind
    securityContext:
      privileged: true
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "1Gi"
        cpu: "1000m"
```

## 🔍 Node Troubleshooting

### **Common Issues and Solutions**

#### **Agent Won't Connect**
```bash
# Check SSH connectivity
ssh -i ~/.ssh/jenkins_key jenkins@agent-host

# Check Java installation
ssh jenkins@agent-host 'java -version'

# Check Jenkins master connectivity
ssh jenkins@agent-host 'telnet jenkins-master 8080'

# Check agent logs
tail -f /var/log/jenkins/agent.log
```

#### **Agent Keeps Disconnecting**
```groovy
// Increase connection timeout
node.getLauncher().setLaunchTimeoutSeconds(120)
node.getLauncher().setMaxNumRetries(5)

// Check for memory issues
// Add JVM options: -Xmx2g -XX:+UseG1GC
```

#### **Builds Stuck in Queue**
```groovy
// Check executor availability
import jenkins.model.*

Jenkins.getInstance().getComputers().each { computer ->
    println "Computer: ${computer.getName()}"
    println "  Online: ${computer.isOnline()}"
    println "  Executors: ${computer.getNumExecutors()}"
    println "  Busy: ${computer.countBusy()}"
    println "  Idle: ${computer.countIdle()}"
}
```

## 📋 Node Maintenance

### **Regular Maintenance Tasks**
```bash
#!/bin/bash
# node-maintenance.sh

# Clean workspace
find /home/jenkins/workspace -type d -mtime +7 -exec rm -rf {} +

# Clean Docker images
docker system prune -f
docker image prune -a -f

# Update system packages
sudo apt update && sudo apt upgrade -y

# Restart Jenkins agent service
sudo systemctl restart jenkins-agent

# Check disk space
df -h | awk '$5 > 80 {print "Warning: " $0}'
```

### **Automated Node Updates**
```groovy
// Update agent tools automatically
import jenkins.model.*
import hudson.tools.*

def jenkins = Jenkins.getInstance()

// Update all tool installations
jenkins.getDescriptorList(ToolInstaller.class).each { descriptor ->
    descriptor.getInstallations().each { installation ->
        if (installation.getInstaller() != null) {
            println "Updating ${installation.getName()}"
            // Trigger update
            installation.getInstaller().performInstallation(null, null)
        }
    }
}
```

## 💡 Best Practices

### **1. Node Sizing**
```
CPU: 1 executor per CPU core
Memory: 2-4GB per executor
Disk: SSD preferred, 100GB+ free space
Network: Gigabit connection to master
```

### **2. Security**
```
- Use SSH keys instead of passwords
- Restrict network access to Jenkins master
- Regular security updates
- Monitor agent access logs
```

### **3. Monitoring**
```
- Set up node health checks
- Monitor resource utilization
- Alert on node disconnections
- Track build queue metrics
```

### **4. Scalability**
```
- Use cloud agents for peak loads
- Implement auto-scaling policies
- Load balance across multiple agents
- Plan for disaster recovery
```