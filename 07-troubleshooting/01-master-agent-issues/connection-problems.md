# Master-Agent Connection Problems

## 🔗 Connection Issues Overview

Master-agent connection problems are common in distributed Jenkins setups and can cause build failures and resource unavailability.

## 🚨 Common Connection Symptoms

### **Agent Offline Status**
```bash
# Check agent status
curl -u admin:token "http://jenkins:8080/computer/api/json" | jq '.computer[] | {displayName, offline}'

# Agent logs location
tail -f /var/log/jenkins/agents/agent-name.log
```

### **Connection Timeout Errors**
```
java.net.ConnectException: Connection timed out
java.io.IOException: Unexpected termination of the channel
hudson.remoting.ChannelClosedException: Channel is already closed
```

## 🔧 Network Connectivity Issues

### **Firewall Problems**
```bash
# Test connectivity from master to agent
telnet agent-host 22
nc -zv agent-host 22

# Test JNLP port (default 50000)
telnet jenkins-master 50000
nc -zv jenkins-master 50000

# Check firewall rules
sudo iptables -L -n
sudo ufw status
```

### **DNS Resolution Issues**
```bash
# Test DNS resolution
nslookup agent-hostname
dig agent-hostname

# Check /etc/hosts
cat /etc/hosts | grep agent

# Test reverse DNS
nslookup agent-ip-address
```

### **Network Troubleshooting Script**
```bash
#!/bin/bash
# network-test.sh

AGENT_HOST="$1"
JENKINS_PORT="8080"
JNLP_PORT="50000"

echo "Testing connectivity to $AGENT_HOST..."

# Test SSH
if nc -zv "$AGENT_HOST" 22 2>/dev/null; then
    echo "✓ SSH port 22 accessible"
else
    echo "✗ SSH port 22 not accessible"
fi

# Test JNLP
if nc -zv "$AGENT_HOST" "$JNLP_PORT" 2>/dev/null; then
    echo "✓ JNLP port $JNLP_PORT accessible"
else
    echo "✗ JNLP port $JNLP_PORT not accessible"
fi

# Test DNS
if nslookup "$AGENT_HOST" >/dev/null 2>&1; then
    echo "✓ DNS resolution working"
else
    echo "✗ DNS resolution failed"
fi
```

## 🔑 SSH Connection Issues

### **SSH Key Problems**
```bash
# Test SSH connection manually
ssh -i /var/lib/jenkins/.ssh/id_rsa jenkins@agent-host

# Check SSH key permissions
ls -la /var/lib/jenkins/.ssh/
chmod 600 /var/lib/jenkins/.ssh/id_rsa
chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub

# Verify SSH agent
ssh-add -l
ssh-add /var/lib/jenkins/.ssh/id_rsa
```

### **SSH Configuration Issues**
```bash
# Check SSH config
cat /var/lib/jenkins/.ssh/config

# Example SSH config
Host agent-*
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    IdentityFile /var/lib/jenkins/.ssh/id_rsa
```

### **SSH Debugging**
```bash
# Debug SSH connection
ssh -vvv -i /var/lib/jenkins/.ssh/id_rsa jenkins@agent-host

# Check SSH daemon on agent
sudo systemctl status sshd
sudo journalctl -u sshd -f
```

## 🔌 JNLP Connection Issues

### **JNLP Agent Setup**
```bash
# Download agent.jar
wget http://jenkins-master:8080/jnlpJars/agent.jar

# Start JNLP agent
java -jar agent.jar -jnlpUrl http://jenkins-master:8080/computer/agent-name/slave-agent.jnlp -secret <secret>

# With custom JVM options
java -Xmx2g -jar agent.jar -jnlpUrl http://jenkins-master:8080/computer/agent-name/slave-agent.jnlp -secret <secret>
```

### **JNLP Troubleshooting**
```groovy
// Get agent secret via Groovy script
import jenkins.model.Jenkins
import hudson.model.Computer

def agentName = "your-agent-name"
def computer = Jenkins.instance.getComputer(agentName)
def launcher = computer.getLauncher()

if (launcher instanceof hudson.slaves.JNLPLauncher) {
    println "Agent Secret: ${computer.getJnlpMac()}"
} else {
    println "Not a JNLP agent"
}
```

### **JNLP Service Configuration**
```ini
# /etc/systemd/system/jenkins-agent.service
[Unit]
Description=Jenkins Agent
After=network.target

[Service]
Type=simple
User=jenkins
WorkingDirectory=/home/jenkins
ExecStart=/usr/bin/java -jar /home/jenkins/agent.jar -jnlpUrl http://jenkins-master:8080/computer/agent-name/slave-agent.jnlp -secret <secret>
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

## 🐳 Docker Agent Issues

### **Docker Connection Problems**
```bash
# Test Docker connectivity
docker version
docker info

# Check Docker daemon
sudo systemctl status docker
sudo journalctl -u docker -f

# Test Docker socket permissions
ls -la /var/run/docker.sock
sudo usermod -aG docker jenkins
```

### **Docker Agent Configuration**
```groovy
// Docker agent template
import org.jenkinsci.plugins.docker.commons.credentials.DockerServerEndpoint
import com.nirima.jenkins.plugins.docker.DockerCloud
import com.nirima.jenkins.plugins.docker.DockerTemplate

def dockerCloud = new DockerCloud(
    "docker-cloud",
    [new DockerServerEndpoint("tcp://docker-host:2376", "docker-cert-id")],
    10,
    "docker-*"
)

def template = new DockerTemplate(
    "jenkins/agent:latest",
    "docker-agent",
    "/home/jenkins",
    "jenkins",
    "2",
    "512m",
    "1024m"
)

dockerCloud.addTemplate(template)
Jenkins.instance.clouds.add(dockerCloud)
```

## ⚡ Performance Issues

### **Agent Resource Problems**
```bash
# Check system resources on agent
top
htop
free -h
df -h

# Monitor network usage
iftop
nethogs

# Check Java heap usage
jstat -gc <java-pid>
jmap -histo <java-pid>
```

### **JVM Tuning for Agents**
```bash
# Agent JVM options
export JAVA_OPTS="-Xmx2g -Xms1g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# For JNLP agents
java $JAVA_OPTS -jar agent.jar -jnlpUrl <url> -secret <secret>
```

### **Connection Pool Tuning**
```groovy
// Adjust connection settings
System.setProperty("hudson.slaves.ChannelPinger.pingTimeoutSeconds", "240")
System.setProperty("hudson.slaves.ChannelPinger.pingIntervalSeconds", "300")
System.setProperty("hudson.remoting.Launcher.pingIntervalSec", "300")
```

## 🔍 Diagnostic Commands

### **Master-Side Diagnostics**
```groovy
// Check agent status
import jenkins.model.Jenkins
import hudson.model.Computer

Jenkins.instance.computers.each { computer ->
    println "Agent: ${computer.name}"
    println "Online: ${computer.isOnline()}"
    println "Offline Cause: ${computer.getOfflineCause()}"
    println "Channel: ${computer.getChannel()}"
    println "---"
}
```

### **Agent Log Analysis**
```bash
# Common error patterns
grep -i "connection" /var/log/jenkins/jenkins.log
grep -i "timeout" /var/log/jenkins/jenkins.log
grep -i "channel" /var/log/jenkins/jenkins.log

# Agent-specific logs
tail -f $JENKINS_HOME/logs/slaves/agent-name/slave.log
```

### **Network Monitoring**
```bash
# Monitor connections
netstat -an | grep :50000
ss -tuln | grep :50000

# Check established connections
netstat -an | grep ESTABLISHED | grep jenkins
```

## 🛠️ Quick Fixes

### **Restart Agent Connection**
```groovy
// Restart specific agent
import jenkins.model.Jenkins
import hudson.model.Computer

def agentName = "your-agent-name"
def computer = Jenkins.instance.getComputer(agentName)

if (computer.isOffline()) {
    computer.connect(true)
    println "Reconnecting agent: ${agentName}"
} else {
    computer.disconnect(null)
    Thread.sleep(5000)
    computer.connect(true)
    println "Restarted agent: ${agentName}"
}
```

### **Clear Agent Workspace**
```bash
# On agent machine
rm -rf /home/jenkins/workspace/*
rm -rf /tmp/jenkins-*

# Via Jenkins
curl -X POST "http://jenkins:8080/computer/agent-name/doWipeOutWorkspace" \
  --user admin:token
```

### **Reset Agent Configuration**
```groovy
// Remove and re-add agent
import jenkins.model.Jenkins
import hudson.model.Computer

def agentName = "problematic-agent"
def jenkins = Jenkins.instance

// Remove agent
jenkins.removeNode(jenkins.getNode(agentName))

// Re-add with fresh configuration
// (Add your agent creation code here)
```

## 📋 Troubleshooting Checklist

### **Network Issues**
- [ ] Test connectivity (ping, telnet, nc)
- [ ] Check firewall rules
- [ ] Verify DNS resolution
- [ ] Test port accessibility
- [ ] Check proxy settings

### **Authentication Issues**
- [ ] Verify SSH keys
- [ ] Check file permissions
- [ ] Test manual SSH connection
- [ ] Validate credentials
- [ ] Check known_hosts file

### **Resource Issues**
- [ ] Monitor CPU/memory usage
- [ ] Check disk space
- [ ] Verify Java heap settings
- [ ] Monitor network bandwidth
- [ ] Check system limits

### **Configuration Issues**
- [ ] Validate agent configuration
- [ ] Check Jenkins master settings
- [ ] Verify plugin versions
- [ ] Review system properties
- [ ] Check log files