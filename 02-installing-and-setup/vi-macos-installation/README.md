# macOS Installation Guide

## Overview
This guide covers multiple methods to install Jenkins on macOS, from simple Homebrew installation to manual setup, perfect for development environments and local testing.

## Prerequisites

### System Requirements
```
┌─────────────────────────────────────────────────────────────┐
│                 macOS Prerequisites                         │
├─────────────────────────────────────────────────────────────┤
│ • macOS 10.14 (Mojave) or later                            │
│ • 4GB RAM minimum (8GB recommended)                         │
│ • 10GB free disk space                                      │
│ • Java 8 or 11 (OpenJDK recommended)                       │
│ • Administrator privileges                                  │
│ • Internet connection for downloads                         │
└─────────────────────────────────────────────────────────────┘
```

### Java Installation Check
```bash
# Check if Java is installed
java -version

# Check JAVA_HOME
echo $JAVA_HOME

# If Java is not installed, install OpenJDK
brew install openjdk@11

# Set JAVA_HOME (add to ~/.zshrc or ~/.bash_profile)
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
```

## Method 1: Homebrew Installation (Recommended)

### Install Homebrew (if not already installed)
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify Homebrew installation
brew --version
```

### Install Jenkins via Homebrew
```bash
# Update Homebrew
brew update

# Install Jenkins LTS
brew install jenkins-lts

# Or install Jenkins weekly
brew install jenkins

# Start Jenkins service
brew services start jenkins-lts

# Stop Jenkins service
brew services stop jenkins-lts

# Restart Jenkins service
brew services restart jenkins-lts

# Check service status
brew services list | grep jenkins
```

### Homebrew Configuration
```bash
# Jenkins configuration file location
/usr/local/etc/jenkins-lts/

# Jenkins home directory
/Users/$(whoami)/.jenkins

# Log files location
/usr/local/var/log/jenkins-lts/

# Check Jenkins process
ps aux | grep jenkins

# View Jenkins logs
tail -f /usr/local/var/log/jenkins-lts/jenkins.log
```

## Method 2: Manual Installation

### Download and Install
```bash
# Create Jenkins directory
sudo mkdir -p /opt/jenkins
cd /opt/jenkins

# Download Jenkins LTS WAR file
sudo curl -L https://get.jenkins.io/war-stable/latest/jenkins.war -o jenkins.war

# Make it executable
sudo chmod +x jenkins.war

# Create Jenkins user (optional)
sudo dscl . -create /Users/jenkins
sudo dscl . -create /Users/jenkins UserShell /bin/bash
sudo dscl . -create /Users/jenkins RealName "Jenkins CI"
sudo dscl . -create /Users/jenkins UniqueID 502
sudo dscl . -create /Users/jenkins PrimaryGroupID 20
sudo dscl . -create /Users/jenkins NFSHomeDirectory /Users/jenkins
sudo createhomedir -c -u jenkins

# Set ownership
sudo chown -R jenkins:staff /opt/jenkins
```

### Create Launch Script
```bash
# Create start script
sudo tee /opt/jenkins/start-jenkins.sh << 'EOF'
#!/bin/bash

# Jenkins configuration
export JENKINS_HOME=/Users/jenkins/.jenkins
export JAVA_OPTS="-Xmx2048m -Djava.awt.headless=true"
export JENKINS_OPTS="--httpPort=8080 --ajp13Port=-1"

# Create Jenkins home directory
mkdir -p $JENKINS_HOME

# Start Jenkins
cd /opt/jenkins
java $JAVA_OPTS -jar jenkins.war $JENKINS_OPTS
EOF

# Make script executable
sudo chmod +x /opt/jenkins/start-jenkins.sh

# Run Jenkins
sudo -u jenkins /opt/jenkins/start-jenkins.sh
```

## Method 3: macOS Service (launchd)

### Create Launch Daemon
```xml
<!-- /Library/LaunchDaemons/org.jenkins-ci.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.jenkins-ci</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/java</string>
        <string>-Xmx2048m</string>
        <string>-Djava.awt.headless=true</string>
        <string>-jar</string>
        <string>/opt/jenkins/jenkins.war</string>
        <string>--httpPort=8080</string>
        <string>--ajp13Port=-1</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <true/>
    
    <key>UserName</key>
    <string>jenkins</string>
    
    <key>GroupName</key>
    <string>staff</string>
    
    <key>WorkingDirectory</key>
    <string>/opt/jenkins</string>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>JENKINS_HOME</key>
        <string>/Users/jenkins/.jenkins</string>
    </dict>
    
    <key>StandardOutPath</key>
    <string>/var/log/jenkins/jenkins.log</string>
    
    <key>StandardErrorPath</key>
    <string>/var/log/jenkins/jenkins.log</string>
</dict>
</plist>
```

### Manage Launch Daemon
```bash
# Create log directory
sudo mkdir -p /var/log/jenkins
sudo chown jenkins:staff /var/log/jenkins

# Load the service
sudo launchctl load /Library/LaunchDaemons/org.jenkins-ci.plist

# Start the service
sudo launchctl start org.jenkins-ci

# Stop the service
sudo launchctl stop org.jenkins-ci

# Unload the service
sudo launchctl unload /Library/LaunchDaemons/org.jenkins-ci.plist

# Check service status
sudo launchctl list | grep jenkins
```

## Method 4: Docker on macOS

### Docker Desktop Installation
```bash
# Install Docker Desktop via Homebrew
brew install --cask docker

# Or download from Docker website
# https://www.docker.com/products/docker-desktop

# Verify Docker installation
docker --version
docker-compose --version
```

### Run Jenkins in Docker
```bash
# Simple Docker run
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# With Docker socket access (for Docker builds)
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(which docker):/usr/bin/docker \
  jenkins/jenkins:lts
```

## Development Environment Setup

### IDE Integration
```bash
# Install Visual Studio Code
brew install --cask visual-studio-code

# Install useful VS Code extensions
code --install-extension ms-vscode.vscode-json
code --install-extension redhat.vscode-yaml
code --install-extension ms-python.python

# Install IntelliJ IDEA (optional)
brew install --cask intellij-idea-ce
```

### Development Tools
```bash
# Install Git
brew install git

# Install Maven
brew install maven

# Install Gradle
brew install gradle

# Install Node.js and npm
brew install node

# Install Python
brew install python

# Install Docker CLI tools
brew install docker-compose
brew install kubectl
brew install helm
```

### Jenkins CLI Setup
```bash
# Download Jenkins CLI
curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

# Create alias for convenience (add to ~/.zshrc or ~/.bash_profile)
alias jenkins-cli='java -jar ~/jenkins-cli.jar -s http://localhost:8080'

# Test Jenkins CLI
jenkins-cli help

# Example: List jobs
jenkins-cli list-jobs
```

## Configuration Files

### Environment Configuration
```bash
# ~/.zshrc or ~/.bash_profile
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
export JENKINS_HOME=/Users/$(whoami)/.jenkins
export PATH=$PATH:/usr/local/bin

# Jenkins CLI alias
alias jenkins-cli='java -jar ~/jenkins-cli.jar -s http://localhost:8080'

# Docker aliases
alias dps='docker ps'
alias dlog='docker logs'
alias dexec='docker exec -it'

# Reload configuration
source ~/.zshrc  # or source ~/.bash_profile
```

### Jenkins Configuration
```bash
# Create Jenkins configuration directory
mkdir -p ~/.jenkins

# Create basic Jenkins configuration
cat > ~/.jenkins/config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<hudson>
  <disabledAdministrativeMonitors/>
  <version>2.401.3</version>
  <installStateName>RUNNING</installStateName>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <useSecurity>true</useSecurity>
  <authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy">
    <denyAnonymousReadAccess>true</denyAnonymousReadAccess>
  </authorizationStrategy>
  <securityRealm class="hudson.security.HudsonPrivateSecurityRealm">
    <disableSignup>true</disableSignup>
    <enableCaptcha>false</enableCaptcha>
  </securityRealm>
</hudson>
EOF
```

## Automation Scripts

### Installation Script
```bash
#!/bin/bash
# install-jenkins-macos.sh

set -e

echo "🚀 Installing Jenkins on macOS..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Install Java if not present
if ! command -v java &> /dev/null; then
    echo "Installing OpenJDK 11..."
    brew install openjdk@11
    
    # Set JAVA_HOME
    echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 11)' >> ~/.zshrc
    export JAVA_HOME=$(/usr/libexec/java_home -v 11)
fi

# Install Jenkins
echo "Installing Jenkins LTS..."
brew install jenkins-lts

# Start Jenkins service
echo "Starting Jenkins service..."
brew services start jenkins-lts

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
sleep 30

# Get initial admin password
if [ -f ~/.jenkins/secrets/initialAdminPassword ]; then
    echo "🎉 Jenkins installation completed!"
    echo "📍 Jenkins URL: http://localhost:8080"
    echo "🔑 Initial admin password:"
    cat ~/.jenkins/secrets/initialAdminPassword
else
    echo "⚠️  Initial admin password not found. Check Jenkins logs."
fi

echo "📝 To stop Jenkins: brew services stop jenkins-lts"
echo "📝 To restart Jenkins: brew services restart jenkins-lts"
```

### Backup Script
```bash
#!/bin/bash
# backup-jenkins-macos.sh

BACKUP_DIR="$HOME/jenkins-backups/$(date +%Y%m%d_%H%M%S)"
JENKINS_HOME="$HOME/.jenkins"

echo "Creating Jenkins backup..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Stop Jenkins service
brew services stop jenkins-lts

# Create backup
tar -czf "$BACKUP_DIR/jenkins_home_backup.tar.gz" -C "$HOME" .jenkins

# Start Jenkins service
brew services start jenkins-lts

echo "✅ Backup created: $BACKUP_DIR/jenkins_home_backup.tar.gz"
echo "📁 Backup size: $(du -h "$BACKUP_DIR/jenkins_home_backup.tar.gz" | cut -f1)"
```

### Update Script
```bash
#!/bin/bash
# update-jenkins-macos.sh

echo "🔄 Updating Jenkins..."

# Update Homebrew
brew update

# Upgrade Jenkins
brew upgrade jenkins-lts

# Restart Jenkins service
brew services restart jenkins-lts

echo "✅ Jenkins updated successfully!"
echo "📍 Jenkins URL: http://localhost:8080"
```

## Troubleshooting

### Common Issues and Solutions

#### Port 8080 Already in Use
```bash
# Check what's using port 8080
sudo lsof -i :8080

# Kill process using port 8080
sudo kill -9 $(sudo lsof -t -i:8080)

# Or change Jenkins port
export JENKINS_OPTS="--httpPort=8081"
```

#### Java Version Issues
```bash
# Check Java version
java -version

# List available Java versions
/usr/libexec/java_home -V

# Switch Java version
export JAVA_HOME=$(/usr/libexec/java_home -v 11)

# Make permanent (add to ~/.zshrc)
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 11)' >> ~/.zshrc
```

#### Permission Issues
```bash
# Fix Jenkins home permissions
sudo chown -R $(whoami):staff ~/.jenkins

# Fix Homebrew permissions
sudo chown -R $(whoami):admin /usr/local/*
```

#### Service Won't Start
```bash
# Check service status
brew services list | grep jenkins

# View service logs
tail -f /usr/local/var/log/jenkins-lts/jenkins.log

# Restart service
brew services restart jenkins-lts

# Force restart
brew services stop jenkins-lts
sleep 5
brew services start jenkins-lts
```

## Performance Optimization

### JVM Tuning
```bash
# Set JVM options (add to ~/.zshrc)
export JAVA_OPTS="-Xms1024m -Xmx2048m -XX:+UseG1GC -XX:+UseStringDeduplication"

# For development (lighter settings)
export JAVA_OPTS="-Xms512m -Xmx1024m"
```

### System Optimization
```bash
# Increase file descriptor limits
echo 'ulimit -n 8192' >> ~/.zshrc

# Monitor system resources
top -pid $(pgrep -f jenkins)

# Check disk usage
du -sh ~/.jenkins
```

## Lab Exercises

### Exercise 1: Homebrew Installation
1. Install Jenkins via Homebrew
2. Access Jenkins web interface
3. Complete initial setup wizard

### Exercise 2: Manual Installation
1. Download Jenkins WAR file
2. Create launch script
3. Set up as macOS service

### Exercise 3: Development Environment
1. Install development tools
2. Configure Jenkins CLI
3. Create sample pipeline

### Exercise 4: Backup and Restore
1. Create backup script
2. Test backup process
3. Restore from backup

## Best Practices

### Security
- Use strong admin passwords
- Enable HTTPS for production use
- Regular security updates
- Limit network access

### Performance
- Allocate sufficient memory
- Use SSD storage
- Monitor resource usage
- Regular maintenance

### Development
- Use version control for configurations
- Implement backup strategy
- Test in isolated environment
- Document configurations

## Next Steps

After successful macOS installation:
1. Complete initial configuration
2. Install essential plugins
3. Set up first pipeline
4. Configure development tools integration