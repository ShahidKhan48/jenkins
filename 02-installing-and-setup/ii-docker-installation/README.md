# Docker Installation Guide

## Overview
Docker provides the fastest and most consistent way to run Jenkins across different environments. This guide covers both simple Docker run commands and advanced Docker Compose setups.

## Prerequisites

### System Requirements
```
┌─────────────────────────────────────────────────────────────┐
│                Docker Prerequisites                         │
├─────────────────────────────────────────────────────────────┤
│ • Docker Engine 20.10 or later                             │
│ • Docker Compose 1.29 or later                             │
│ • 4GB RAM minimum (8GB recommended)                         │
│ • 20GB disk space minimum                                   │
│ • Network access for image downloads                        │
└─────────────────────────────────────────────────────────────┘
```

### Docker Installation Verification
```bash
# Verify Docker installation
docker --version
docker-compose --version

# Test Docker functionality
docker run hello-world
```

## Method 1: Simple Docker Run

### Basic Jenkins Container
```bash
# Pull the latest Jenkins LTS image
docker pull jenkins/jenkins:lts

# Run Jenkins container
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

### With Docker Socket Access (for Docker builds)
```bash
# Run Jenkins with Docker socket mounted
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(which docker):/usr/bin/docker \
  jenkins/jenkins:lts
```

### Container Management Commands
```bash
# Start Jenkins container
docker start jenkins

# Stop Jenkins container
docker stop jenkins

# View Jenkins logs
docker logs jenkins

# Follow Jenkins logs in real-time
docker logs -f jenkins

# Access Jenkins container shell
docker exec -it jenkins bash

# Remove Jenkins container
docker rm jenkins

# Remove Jenkins volume (WARNING: This deletes all data)
docker volume rm jenkins_home
```

## Method 2: Docker Compose Setup

### Basic Docker Compose Configuration
```yaml
# docker-compose.yml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false
      - JENKINS_OPTS=--httpPort=8080
    networks:
      - jenkins

volumes:
  jenkins_home:
    driver: local

networks:
  jenkins:
    driver: bridge
```

### Advanced Docker Compose with Nginx
```yaml
# docker-compose.yml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: unless-stopped
    ports:
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false -Xmx2048m
      - JENKINS_OPTS=--httpPort=8080 --prefix=/jenkins
    networks:
      - jenkins

  nginx:
    image: nginx:alpine
    container_name: jenkins-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - jenkins
    networks:
      - jenkins

volumes:
  jenkins_home:
    driver: local

networks:
  jenkins:
    driver: bridge
```

### Nginx Configuration for Jenkins
```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream jenkins {
        server jenkins:8080;
    }

    server {
        listen 80;
        server_name jenkins.yourdomain.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl;
        server_name jenkins.yourdomain.com;

        ssl_certificate /etc/nginx/ssl/jenkins.crt;
        ssl_certificate_key /etc/nginx/ssl/jenkins.key;

        location /jenkins/ {
            proxy_pass http://jenkins/jenkins/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_redirect http:// https://;
        }
    }
}
```

## Method 3: Custom Jenkins Docker Image

### Dockerfile for Custom Jenkins
```dockerfile
# Dockerfile
FROM jenkins/jenkins:lts

# Switch to root user to install additional packages
USER root

# Install additional tools
RUN apt-get update && apt-get install -y \
    curl \
    vim \
    git \
    maven \
    nodejs \
    npm \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Copy plugins list
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Install plugins
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copy custom configuration
COPY jenkins.yaml /var/jenkins_home/casc_configs/jenkins.yaml

# Switch back to jenkins user
USER jenkins

# Set environment variables
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG="/var/jenkins_home/casc_configs"
```

### Essential Plugins List
```text
# plugins.txt
ant:latest
build-timeout:latest
credentials-binding:latest
email-ext:latest
git:latest
github-branch-source:latest
gradle:latest
ldap:latest
mailer:latest
matrix-auth:latest
pam-auth:latest
pipeline-github-lib:latest
pipeline-stage-view:latest
ssh-slaves:latest
timestamper:latest
workflow-aggregator:latest
ws-cleanup:latest
blueocean:latest
docker-workflow:latest
kubernetes:latest
configuration-as-code:latest
```

### Build and Run Custom Image
```bash
# Build custom Jenkins image
docker build -t my-jenkins:latest .

# Run custom Jenkins container
docker run -d \
  --name my-jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  my-jenkins:latest
```

## Method 4: Jenkins with Docker Agents

### Docker Compose with Jenkins and Agents
```yaml
# docker-compose.yml
version: '3.8'

services:
  jenkins-master:
    image: jenkins/jenkins:lts
    container_name: jenkins-master
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false
    networks:
      - jenkins

  jenkins-agent-1:
    image: jenkins/inbound-agent:latest
    container_name: jenkins-agent-1
    restart: unless-stopped
    environment:
      - JENKINS_URL=http://jenkins-master:8080
      - JENKINS_SECRET=${JENKINS_AGENT_SECRET}
      - JENKINS_AGENT_NAME=docker-agent-1
      - JENKINS_AGENT_WORKDIR=/home/jenkins/agent
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
    depends_on:
      - jenkins-master
    networks:
      - jenkins

  jenkins-agent-2:
    image: jenkins/inbound-agent:latest
    container_name: jenkins-agent-2
    restart: unless-stopped
    environment:
      - JENKINS_URL=http://jenkins-master:8080
      - JENKINS_SECRET=${JENKINS_AGENT_SECRET}
      - JENKINS_AGENT_NAME=docker-agent-2
      - JENKINS_AGENT_WORKDIR=/home/jenkins/agent
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
    depends_on:
      - jenkins-master
    networks:
      - jenkins

volumes:
  jenkins_home:
    driver: local

networks:
  jenkins:
    driver: bridge
```

### Environment Variables File
```bash
# .env
JENKINS_AGENT_SECRET=your-agent-secret-here
```

## Configuration as Code (JCasC)

### Jenkins Configuration YAML
```yaml
# jenkins.yaml
jenkins:
  systemMessage: "Jenkins configured automatically by Jenkins Configuration as Code plugin"
  
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: admin
          password: ${JENKINS_ADMIN_PASSWORD}
          
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"

  remotingSecurity:
    enabled: true

tool:
  git:
    installations:
      - name: "Default"
        home: "/usr/bin/git"
        
  maven:
    installations:
      - name: "Maven-3.8.1"
        home: "/opt/maven"

unclassified:
  location:
    url: "http://localhost:8080/"
    adminAddress: "admin@company.com"
    
  globalLibraries:
    libraries:
      - name: "shared-library"
        defaultVersion: "main"
        retriever:
          modernSCM:
            scm:
              git:
                remote: "https://github.com/company/jenkins-shared-library.git"
```

## Docker Management Scripts

### Start Script
```bash
#!/bin/bash
# start-jenkins.sh

echo "Starting Jenkins with Docker Compose..."

# Create necessary directories
mkdir -p ./ssl
mkdir -p ./logs

# Start services
docker-compose up -d

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
sleep 30

# Display initial admin password
echo "Jenkins is starting up..."
echo "Initial admin password:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo "Jenkins will be available at: http://localhost:8080"
```

### Backup Script
```bash
#!/bin/bash
# backup-jenkins.sh

BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "Creating Jenkins backup..."

# Stop Jenkins
docker-compose stop jenkins

# Create backup
docker run --rm \
  -v jenkins_home:/source:ro \
  -v $(pwd)/$BACKUP_DIR:/backup \
  alpine:latest \
  tar czf /backup/jenkins_home_backup.tar.gz -C /source .

# Start Jenkins
docker-compose start jenkins

echo "Backup created: $BACKUP_DIR/jenkins_home_backup.tar.gz"
```

### Restore Script
```bash
#!/bin/bash
# restore-jenkins.sh

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

BACKUP_FILE=$1

echo "Restoring Jenkins from backup: $BACKUP_FILE"

# Stop Jenkins
docker-compose stop jenkins

# Restore backup
docker run --rm \
  -v jenkins_home:/target \
  -v $(pwd):/backup \
  alpine:latest \
  tar xzf /backup/$BACKUP_FILE -C /target

# Start Jenkins
docker-compose start jenkins

echo "Restore completed"
```

## Monitoring and Maintenance

### Health Check Script
```bash
#!/bin/bash
# health-check.sh

JENKINS_URL="http://localhost:8080"

# Check if Jenkins is responding
if curl -f -s $JENKINS_URL/login > /dev/null; then
    echo "✅ Jenkins is healthy"
else
    echo "❌ Jenkins is not responding"
    exit 1
fi

# Check disk space
DISK_USAGE=$(docker exec jenkins df -h /var/jenkins_home | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "⚠️  Disk usage is high: ${DISK_USAGE}%"
else
    echo "✅ Disk usage is normal: ${DISK_USAGE}%"
fi

# Check memory usage
MEMORY_USAGE=$(docker stats jenkins --no-stream --format "table {{.MemPerc}}" | tail -n 1 | sed 's/%//')
if (( $(echo "$MEMORY_USAGE > 80" | bc -l) )); then
    echo "⚠️  Memory usage is high: ${MEMORY_USAGE}%"
else
    echo "✅ Memory usage is normal: ${MEMORY_USAGE}%"
fi
```

## Troubleshooting

### Common Issues and Solutions

#### Port Already in Use
```bash
# Check what's using port 8080
sudo lsof -i :8080

# Kill process using port 8080
sudo kill -9 $(sudo lsof -t -i:8080)

# Or use different port
docker run -p 8081:8080 jenkins/jenkins:lts
```

#### Permission Issues
```bash
# Fix Docker socket permissions
sudo chmod 666 /var/run/docker.sock

# Or add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

#### Container Won't Start
```bash
# Check container logs
docker logs jenkins

# Check system resources
docker system df
docker system prune

# Restart Docker service
sudo systemctl restart docker
```

## Lab Exercises

### Exercise 1: Basic Docker Installation
1. Install Jenkins using simple docker run command
2. Access Jenkins web interface
3. Complete initial setup wizard

### Exercise 2: Docker Compose Setup
1. Create docker-compose.yml file
2. Add nginx reverse proxy
3. Configure SSL certificates

### Exercise 3: Custom Jenkins Image
1. Create Dockerfile with additional tools
2. Build and run custom image
3. Verify installed tools

### Exercise 4: Backup and Restore
1. Create backup script
2. Test backup process
3. Restore from backup

## Best Practices

### Security
- Use specific image tags instead of 'latest'
- Run containers as non-root user when possible
- Regularly update base images
- Use secrets management for sensitive data

### Performance
- Allocate sufficient memory (4GB minimum)
- Use SSD storage for better I/O performance
- Monitor container resource usage
- Implement log rotation

### Maintenance
- Regular backups of jenkins_home volume
- Monitor disk space usage
- Keep Docker and images updated
- Implement health checks

## Next Steps

After successful Docker installation:
1. Complete initial configuration
2. Install essential plugins
3. Set up first pipeline
4. Configure agents if needed