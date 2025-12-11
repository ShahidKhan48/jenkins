# Agent Labels

## 🏷️ What are Agent Labels?

Agent labels are tags assigned to Jenkins agents that allow pipelines to specify where they should run based on capabilities, operating system, or other characteristics.

## 🎯 Agent Syntax

### **Global Agent**
```groovy
pipeline {
    agent any  // Run on any available agent
    stages {
        stage('Build') {
            steps {
                echo 'Running on any agent'
            }
        }
    }
}
```

### **Label-based Agent**
```groovy
pipeline {
    agent {
        label 'linux'  // Run on agents with 'linux' label
    }
    stages {
        stage('Build') {
            steps {
                echo 'Running on Linux agent'
            }
        }
    }
}
```

### **No Global Agent**
```groovy
pipeline {
    agent none  // Don't allocate agent globally
    stages {
        stage('Build') {
            agent {
                label 'maven'  // Specify agent per stage
            }
            steps {
                sh 'mvn clean compile'
            }
        }
    }
}
```

## 🔧 Agent Types

### **1. Any Agent**
```groovy
agent any
```

### **2. None**
```groovy
agent none
```

### **3. Label**
```groovy
agent {
    label 'linux && docker'  // Multiple labels with AND
}

agent {
    label 'windows || macos'  // Multiple labels with OR
}
```

### **4. Node**
```groovy
agent {
    node {
        label 'linux'
        customWorkspace '/tmp/my-workspace'
    }
}
```

### **5. Docker**
```groovy
agent {
    docker {
        image 'maven:3.8.1-openjdk-11'
        label 'docker'
        args '-v /tmp:/tmp'
    }
}
```

### **6. Dockerfile**
```groovy
agent {
    dockerfile {
        filename 'Dockerfile.build'
        dir 'docker'
        label 'docker'
    }
}
```

### **7. Kubernetes**
```groovy
agent {
    kubernetes {
        yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: maven
            image: maven:3.8.1-openjdk-11
            command: ['cat']
            tty: true
        '''
    }
}
```

## 🏷️ Common Label Examples

### **Operating System Labels**
```groovy
agent { label 'linux' }
agent { label 'windows' }
agent { label 'macos' }
```

### **Architecture Labels**
```groovy
agent { label 'x86_64' }
agent { label 'arm64' }
```

### **Tool-specific Labels**
```groovy
agent { label 'maven' }
agent { label 'nodejs' }
agent { label 'docker' }
agent { label 'kubernetes' }
```

### **Environment Labels**
```groovy
agent { label 'production' }
agent { label 'staging' }
agent { label 'development' }
```

### **Capability Labels**
```groovy
agent { label 'gpu' }
agent { label 'high-memory' }
agent { label 'ssd-storage' }
```

## 🔍 Label Expressions

### **AND Operator**
```groovy
agent {
    label 'linux && docker && maven'  // Must have all labels
}
```

### **OR Operator**
```groovy
agent {
    label 'linux || windows'  // Can have either label
}
```

### **NOT Operator**
```groovy
agent {
    label 'linux && !windows'  // Linux but not Windows
}
```

### **Parentheses for Grouping**
```groovy
agent {
    label '(linux || windows) && docker'
}
```

## 🎯 Stage-specific Agents

### **Different Agents per Stage**
```groovy
pipeline {
    agent none
    stages {
        stage('Build') {
            agent {
                label 'maven'
            }
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('Test') {
            agent {
                label 'testing'
            }
            steps {
                sh 'mvn test'
            }
        }
        stage('Deploy') {
            agent {
                label 'production'
            }
            steps {
                sh 'deploy.sh'
            }
        }
    }
}
```

### **Parallel Stages with Different Agents**
```groovy
pipeline {
    agent none
    stages {
        stage('Parallel Tests') {
            parallel {
                stage('Linux Tests') {
                    agent {
                        label 'linux'
                    }
                    steps {
                        sh 'run-linux-tests.sh'
                    }
                }
                stage('Windows Tests') {
                    agent {
                        label 'windows'
                    }
                    steps {
                        bat 'run-windows-tests.bat'
                    }
                }
            }
        }
    }
}
```

## 🔧 Agent Configuration

### **Setting Labels on Agents**
1. Go to **Manage Jenkins** → **Manage Nodes**
2. Click on agent name
3. Click **Configure**
4. Add labels in **Labels** field: `linux docker maven`

### **Dynamic Agent Provisioning**
```groovy
agent {
    kubernetes {
        label 'dynamic-pod'
        yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            jenkins: agent
        spec:
          containers:
          - name: maven
            image: maven:3.8.1-openjdk-11
            command: ['cat']
            tty: true
            resources:
              requests:
                memory: "1Gi"
                cpu: "500m"
        '''
    }
}
```

## 📊 Agent Selection Strategy

### **Load Balancing**
```groovy
// Jenkins automatically selects least busy agent
agent {
    label 'linux'  // Will pick from available Linux agents
}
```

### **Specific Node**
```groovy
agent {
    node {
        label 'specific-node-name'
    }
}
```

### **Custom Workspace**
```groovy
agent {
    node {
        label 'linux'
        customWorkspace '/opt/jenkins/workspace/my-project'
    }
}
```

## 💡 Best Practices

### **1. Use Descriptive Labels**
```groovy
// Good
agent { label 'linux-docker-maven-jdk11' }

// Bad
agent { label 'agent1' }
```

### **2. Combine Multiple Labels**
```groovy
agent {
    label 'linux && docker && !gpu'  // Linux with Docker but no GPU
}
```

### **3. Use Stage-specific Agents**
```groovy
pipeline {
    agent none
    stages {
        stage('Build') {
            agent { label 'build-agents' }
            steps { /* build steps */ }
        }
        stage('Deploy') {
            agent { label 'deploy-agents' }
            steps { /* deploy steps */ }
        }
    }
}
```

### **4. Handle Agent Unavailability**
```groovy
pipeline {
    agent {
        label 'preferred-agent || backup-agent'
    }
    stages {
        stage('Build') {
            steps {
                echo "Running on: ${env.NODE_NAME}"
            }
        }
    }
}
```

## 🚨 Common Issues

### **No Agents Available**
```groovy
// Error: There are no nodes with the label 'nonexistent'
agent { label 'nonexistent' }

// Solution: Check available labels
agent { label 'linux' }  // Ensure this label exists
```

### **Agent Offline**
```groovy
// Pipeline will wait for agent to come online
// Or fail after timeout
options {
    timeout(time: 10, unit: 'MINUTES')
}
```

### **Resource Constraints**
```groovy
// Specify resource requirements for K8s agents
agent {
    kubernetes {
        yaml '''
        spec:
          containers:
          - name: maven
            resources:
              requests:
                memory: "2Gi"
                cpu: "1000m"
        '''
    }
}
```