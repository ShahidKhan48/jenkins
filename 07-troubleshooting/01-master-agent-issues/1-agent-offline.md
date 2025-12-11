# Agent Offline Issues

## 🚨 Common Symptoms
- Agent shows as offline in Jenkins UI
- Builds fail with "Agent is offline" error
- Connection lost during build execution

## 🔍 Diagnostic Steps

### **1. Check Agent Status**
```bash
# Jenkins UI: Manage Jenkins → Manage Nodes
# Look for red X next to agent name
```

### **2. Network Connectivity**
```bash
# From Jenkins master
ping agent-hostname
telnet agent-hostname 22

# From agent to master
ping jenkins-master
telnet jenkins-master 8080
```

### **3. SSH Connection Test**
```bash
# Test SSH manually
ssh -i /var/lib/jenkins/.ssh/id_rsa jenkins@agent-hostname
```

## 🛠️ Common Causes & Solutions

### **1. Network Issues**
**Problem**: Firewall blocking connection
```bash
# Check firewall status
sudo ufw status
sudo firewall-cmd --list-all
```

**Solution**: Open required ports
```bash
# Allow SSH (port 22)
sudo ufw allow 22
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --reload
```

### **2. SSH Key Problems**
**Problem**: Authentication failure
```bash
# Check SSH key permissions
ls -la /var/lib/jenkins/.ssh/
```

**Solution**: Fix permissions
```bash
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa
sudo chmod 600 /var/lib/jenkins/.ssh/id_rsa
```

### **3. Java Issues**
**Problem**: Java version mismatch
```bash
# Check Java versions
java -version  # On master
ssh jenkins@agent "java -version"  # On agent
```

**Solution**: Install compatible Java
```bash
sudo apt install openjdk-11-jdk
```

### **4. Disk Space**
**Problem**: Agent disk full
```bash
ssh jenkins@agent "df -h"
```

**Solution**: Clean up space
```bash
# Clean workspace
sudo rm -rf /home/jenkins/workspace/*
# Clean logs
sudo journalctl --vacuum-time=7d
```

## 🔄 Recovery Procedures

### **Manual Reconnection**
1. Go to Manage Jenkins → Manage Nodes
2. Click on offline agent
3. Click "Launch agent"
4. Follow connection instructions

### **Automated Recovery Script**
```bash
#!/bin/bash
AGENT_NAME="agent-1"
JENKINS_URL="http://jenkins:8080"

# Check if agent is offline
if curl -s "$JENKINS_URL/computer/$AGENT_NAME/api/json" | grep -q '"offline":true'; then
    echo "Agent is offline, attempting recovery..."
    # Restart agent service
    ssh jenkins@$AGENT_NAME "sudo systemctl restart jenkins-agent"
fi
```