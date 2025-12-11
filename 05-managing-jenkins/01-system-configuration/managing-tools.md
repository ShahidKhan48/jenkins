# Managing Tools

## 🛠️ Global Tool Configuration

Jenkins Global Tool Configuration allows you to define tools that can be automatically installed and made available to builds across all jobs.

## 📍 Accessing Tool Configuration

**Navigate to:** Manage Jenkins → Global Tool Configuration

## ☕ JDK Configuration

### **Manual JDK Installation**
```
Name: JDK-11
JAVA_HOME: /usr/lib/jvm/java-11-openjdk
```

### **Automatic JDK Installation**
```
Name: JDK-17
Install automatically: ✓
Installer: Install from adoptium.net
Version: jdk-17.0.1+12
```

### **Multiple JDK Versions**
```
JDK Installations:
├── JDK-8  → /usr/lib/jvm/java-8-openjdk
├── JDK-11 → /usr/lib/jvm/java-11-openjdk
└── JDK-17 → Auto-install from adoptium.net
```

### **Using JDK in Pipeline**
```groovy
pipeline {
    agent any
    tools {
        jdk 'JDK-11'
    }
    stages {
        stage('Build') {
            steps {
                sh 'java -version'
                sh 'javac -version'
            }
        }
    }
}
```

## 🔨 Maven Configuration

### **Manual Maven Setup**
```
Name: Maven-3.8.1
MAVEN_HOME: /opt/maven/apache-maven-3.8.1
```

### **Automatic Maven Installation**
```
Name: Maven-Latest
Install automatically: ✓
Installer: Install from Apache
Version: 3.8.6
```

### **Maven in Pipeline**
```groovy
pipeline {
    agent any
    tools {
        maven 'Maven-3.8.1'
        jdk 'JDK-11'
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn --version'
                sh 'mvn clean compile'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
    }
}
```

## 🐘 Gradle Configuration

### **Gradle Setup**
```
Name: Gradle-7.4
Install automatically: ✓
Installer: Install from Gradle.org
Version: 7.4.2
```

### **Gradle Wrapper Support**
```groovy
pipeline {
    agent any
    stages {
        stage('Build with Wrapper') {
            steps {
                sh './gradlew build'
            }
        }
        stage('Build with Tool') {
            tools {
                gradle 'Gradle-7.4'
            }
            steps {
                sh 'gradle build'
            }
        }
    }
}
```

## 🌐 Node.js Configuration

### **Node.js Installation**
```
Name: NodeJS-16
Install automatically: ✓
Installer: Install from nodejs.org
Version: 16.14.0
Global npm packages to install: yarn@1.22.17 typescript@4.6.2
```

### **Node.js in Pipeline**
```groovy
pipeline {
    agent any
    tools {
        nodejs 'NodeJS-16'
    }
    stages {
        stage('Install Dependencies') {
            steps {
                sh 'node --version'
                sh 'npm --version'
                sh 'npm install'
            }
        }
        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
    }
}
```

## 🐍 Python Configuration

### **Python Tool Setup**
```
Name: Python-3.9
Install automatically: ✓
Installer: Command
Command: 
  curl -O https://www.python.org/ftp/python/3.9.12/Python-3.9.12.tgz
  tar -xzf Python-3.9.12.tgz
  cd Python-3.9.12
  ./configure --prefix=$TOOL_HOME
  make && make install
```

### **Python in Pipeline**
```groovy
pipeline {
    agent any
    environment {
        PATH = "${tool 'Python-3.9'}/bin:${env.PATH}"
    }
    stages {
        stage('Setup') {
            steps {
                sh 'python3 --version'
                sh 'pip3 install -r requirements.txt'
            }
        }
        stage('Test') {
            steps {
                sh 'python3 -m pytest'
            }
        }
    }
}
```

## 🔧 Git Configuration

### **Git Tool Setup**
```
Name: Default
Path to Git executable: /usr/bin/git
```

### **Multiple Git Versions**
```
Git Installations:
├── Default → /usr/bin/git
├── Git-2.35 → /opt/git/2.35/bin/git
└── Git-Latest → Auto-install from git-scm.com
```

### **Git in Pipeline**
```groovy
pipeline {
    agent any
    tools {
        git 'Git-2.35'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/user/repo.git'
                sh 'git --version'
            }
        }
    }
}
```

## 🐳 Docker Configuration

### **Docker Tool Setup**
```
Name: Docker
Installation directory: /usr/bin/docker
```

### **Docker in Pipeline**
```groovy
pipeline {
    agent any
    tools {
        dockerTool 'Docker'
    }
    stages {
        stage('Build Image') {
            steps {
                sh 'docker --version'
                sh 'docker build -t myapp:${BUILD_NUMBER} .'
            }
        }
        stage('Push Image') {
            steps {
                sh 'docker push myapp:${BUILD_NUMBER}'
            }
        }
    }
}
```

## ☸️ Kubernetes Tools

### **kubectl Configuration**
```groovy
// Custom tool installation
pipeline {
    agent any
    stages {
        stage('Install kubectl') {
            steps {
                sh '''
                    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                    chmod +x kubectl
                    sudo mv kubectl /usr/local/bin/
                '''
            }
        }
        stage('Deploy') {
            steps {
                sh 'kubectl apply -f k8s/'
            }
        }
    }
}
```

### **Helm Configuration**
```groovy
pipeline {
    agent any
    stages {
        stage('Install Helm') {
            steps {
                sh '''
                    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                '''
            }
        }
        stage('Deploy with Helm') {
            steps {
                sh 'helm upgrade --install myapp ./helm-chart'
            }
        }
    }
}
```

## 🔧 Custom Tool Installation

### **Custom Tool Script**
```bash
#!/bin/bash
# install-custom-tool.sh

TOOL_VERSION="1.2.3"
TOOL_HOME="$1"

# Download and install custom tool
wget https://releases.example.com/tool-${TOOL_VERSION}.tar.gz
tar -xzf tool-${TOOL_VERSION}.tar.gz
mv tool-${TOOL_VERSION}/* ${TOOL_HOME}/
chmod +x ${TOOL_HOME}/bin/tool
```

### **Custom Tool Configuration**
```
Name: CustomTool-1.2.3
Install automatically: ✓
Installer: Run Command
Command: /path/to/install-custom-tool.sh
Tool Home: $TOOL_HOME
```

## 🎯 Tool Configuration Strategies

### **Environment-specific Tools**
```groovy
pipeline {
    agent any
    tools {
        jdk "${params.JAVA_VERSION ?: 'JDK-11'}"
        maven "${params.MAVEN_VERSION ?: 'Maven-3.8.1'}"
    }
    parameters {
        choice(
            name: 'JAVA_VERSION',
            choices: ['JDK-8', 'JDK-11', 'JDK-17'],
            description: 'Java version to use'
        )
        choice(
            name: 'MAVEN_VERSION',
            choices: ['Maven-3.6.3', 'Maven-3.8.1', 'Maven-3.8.6'],
            description: 'Maven version to use'
        )
    }
    stages {
        stage('Build') {
            steps {
                sh 'java -version && mvn --version'
            }
        }
    }
}
```

### **Matrix Builds with Different Tools**
```groovy
pipeline {
    agent none
    stages {
        stage('Matrix Build') {
            matrix {
                axes {
                    axis {
                        name 'JAVA_VERSION'
                        values 'JDK-8', 'JDK-11', 'JDK-17'
                    }
                    axis {
                        name 'MAVEN_VERSION'
                        values 'Maven-3.6.3', 'Maven-3.8.1'
                    }
                }
                stages {
                    stage('Build') {
                        agent any
                        tools {
                            jdk "${JAVA_VERSION}"
                            maven "${MAVEN_VERSION}"
                        }
                        steps {
                            sh 'mvn clean test'
                        }
                    }
                }
            }
        }
    }
}
```

## 📦 Tool Installation Automation

### **Ansible Playbook for Tools**
```yaml
# install-jenkins-tools.yml
---
- hosts: jenkins-master
  become: yes
  tasks:
    - name: Install OpenJDK 11
      package:
        name: openjdk-11-jdk
        state: present
    
    - name: Download Maven
      get_url:
        url: "https://archive.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz"
        dest: "/tmp/maven.tar.gz"
    
    - name: Extract Maven
      unarchive:
        src: "/tmp/maven.tar.gz"
        dest: "/opt"
        remote_src: yes
        creates: "/opt/apache-maven-3.8.1"
    
    - name: Create Maven symlink
      file:
        src: "/opt/apache-maven-3.8.1"
        dest: "/opt/maven"
        state: link
```

### **Docker-based Tool Management**
```dockerfile
# Dockerfile for Jenkins with tools
FROM jenkins/jenkins:lts

USER root

# Install tools
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    maven \
    nodejs \
    npm \
    python3 \
    python3-pip \
    docker.io

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

USER jenkins
```

## 🔍 Tool Troubleshooting

### **Common Issues**

#### **Tool Not Found**
```groovy
// Error: Tool 'Maven-3.8.1' not found
pipeline {
    agent any
    tools {
        maven 'Maven-3.8.1'  // Check exact name in Global Tool Configuration
    }
}
```

#### **Path Issues**
```groovy
// Solution: Verify tool installation
pipeline {
    agent any
    tools {
        maven 'Maven-3.8.1'
    }
    stages {
        stage('Debug') {
            steps {
                sh 'echo $PATH'
                sh 'which mvn'
                sh 'mvn --version'
            }
        }
    }
}
```

#### **Permission Issues**
```bash
# Fix tool permissions
sudo chown -R jenkins:jenkins /opt/maven
sudo chmod +x /opt/maven/bin/mvn
```

## 💡 Best Practices

### **1. Consistent Naming**
```
JDK-8, JDK-11, JDK-17
Maven-3.6.3, Maven-3.8.1, Maven-3.8.6
NodeJS-14, NodeJS-16, NodeJS-18
```

### **2. Version Management**
```groovy
// Use parameters for tool versions
parameters {
    choice(name: 'JDK_VERSION', choices: ['JDK-8', 'JDK-11', 'JDK-17'])
}

tools {
    jdk "${params.JDK_VERSION}"
}
```

### **3. Tool Validation**
```groovy
stage('Validate Tools') {
    steps {
        sh 'java -version'
        sh 'mvn --version'
        sh 'node --version'
        sh 'docker --version'
    }
}
```

### **4. Fallback Strategies**
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    try {
                        // Try with configured tool
                        sh 'mvn clean compile'
                    } catch (Exception e) {
                        // Fallback to system Maven
                        sh '/usr/bin/mvn clean compile'
                    }
                }
            }
        }
    }
}
```