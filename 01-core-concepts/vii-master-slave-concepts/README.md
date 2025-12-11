# Master-Slave Concepts in Jenkins

## Overview of Master-Slave Architecture

The Jenkins Master-Slave (now called Controller-Agent) architecture is designed to distribute build workloads across multiple machines, providing scalability, platform diversity, and resource optimization.

## Jenkins Master (Controller) Deep Dive

### Primary Responsibilities

#### 1. Job Management
```
┌─────────────────────────────────────┐
│         Job Management              │
├─────────────────────────────────────┤
│ • Job Creation & Configuration      │
│ • Build Scheduling                  │
│ • Queue Management                  │
│ • Build History Tracking           │
│ • Artifact Storage                  │
└─────────────────────────────────────┘
```

#### 2. Agent Coordination
```
┌─────────────────────────────────────┐
│       Agent Coordination            │
├─────────────────────────────────────┤
│ • Agent Registration                │
│ • Health Monitoring                 │
│ • Load Distribution                 │
│ • Communication Management          │
│ • Resource Allocation               │
└─────────────────────────────────────┘
```

#### 3. System Administration
```
┌─────────────────────────────────────┐
│      System Administration          │
├─────────────────────────────────────┤
│ • Plugin Management                 │
│ • Security Configuration            │
│ • System Configuration              │
│ • User Management                   │
│ • Backup & Maintenance              │
└─────────────────────────────────────┘
```

### Master Resource Requirements

#### Minimum Requirements
```
┌─────────────────────────────────────┐
│       Minimum Specifications        │
├─────────────────────────────────────┤
│ CPU:    2 cores                     │
│ RAM:    4 GB                        │
│ Disk:   50 GB                       │
│ Java:   OpenJDK 8 or 11            │
│ OS:     Linux/Windows/macOS         │
└─────────────────────────────────────┘
```

#### Recommended for Production
```
┌─────────────────────────────────────┐
│     Production Specifications       │
├─────────────────────────────────────┤
│ CPU:    4-8 cores                   │
│ RAM:    8-16 GB                     │
│ Disk:   200+ GB SSD                 │
│ Java:   OpenJDK 11 LTS              │
│ OS:     Linux (Ubuntu/RHEL)         │
└─────────────────────────────────────┘
```

## Jenkins Agents (Slaves) Deep Dive

### Agent Types and Characteristics

#### 1. Permanent Agents
```
┌─────────────────────────────────────────────────────────────┐
│                    Permanent Agents                         │
├─────────────────────────────────────────────────────────────┤
│ Characteristics:                                            │
│ • Always available and connected                            │
│ • Dedicated hardware or VM                                  │
│ • Consistent build environment                              │
│ • Manual provisioning and management                        │
│                                                             │
│ Best Use Cases:                                             │
│ • Stable, long-running workloads                            │
│ • Builds requiring specific hardware                        │
│ • Legacy applications with complex dependencies             │
│ • High-security environments                                │
│                                                             │
│ Configuration Example:                                      │
│ Name: linux-build-01                                        │
│ Labels: linux, java, maven                                  │
│ Executors: 4                                                │
│ Remote Root: /home/jenkins                                  │
└─────────────────────────────────────────────────────────────┘
```

#### 2. Cloud Agents
```
┌─────────────────────────────────────────────────────────────┐
│                     Cloud Agents                           │
├─────────────────────────────────────────────────────────────┤
│ Characteristics:                                            │
│ • On-demand provisioning                                    │
│ • Auto-scaling based on workload                            │
│ • Cost-effective for variable workloads                     │
│ • Automatic lifecycle management                            │
│                                                             │
│ Supported Platforms:                                        │
│ • Amazon EC2                                                │
│ • Google Cloud Platform                                     │
│ • Microsoft Azure                                           │
│ • Docker containers                                         │
│ • Kubernetes pods                                           │
│                                                             │
│ Benefits:                                                   │
│ • Reduced infrastructure costs                              │
│ • Elastic scaling                                           │
│ • Fresh environment for each build                          │
│ • Platform diversity                                        │
└─────────────────────────────────────────────────────────────┘
```

#### 3. Docker Agents
```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Agents                           │
├─────────────────────────────────────────────────────────────┤
│ Pipeline Example:                                           │
│                                                             │
│ pipeline {                                                  │
│     agent {                                                 │
│         docker {                                            │
│             image 'maven:3.8.1-openjdk-11'                 │
│             args '-v /var/run/docker.sock:/var/run/docker.sock' │
│         }                                                   │
│     }                                                       │
│     stages {                                                │
│         stage('Build') {                                    │
│             steps {                                         │
│                 sh 'mvn clean compile'                      │
│             }                                               │
│         }                                                   │
│     }                                                       │
│ }                                                           │
│                                                             │
│ Benefits:                                                   │
│ • Isolated build environments                               │
│ • Consistent tooling across builds                          │
│ • Easy environment reproduction                             │
│ • Version-controlled build environments                     │
└─────────────────────────────────────────────────────────────┘
```

### Agent Configuration Parameters

#### Essential Configuration
```
┌─────────────────────────────────────────────────────────────┐
│                Agent Configuration                          │
├─────────────────────────────────────────────────────────────┤
│ Name:           Unique identifier for the agent             │
│ Description:    Purpose and capabilities                    │
│ Labels:         Tags for job targeting                      │
│ Executors:      Number of concurrent builds                 │
│ Remote Root:    Working directory on agent                  │
│ Usage:          How Jenkins uses this agent                 │
│ Launch Method:  How agent connects to master                │
│ Availability:   When agent should be online                 │
└─────────────────────────────────────────────────────────────┘
```

#### Advanced Configuration
```
┌─────────────────────────────────────────────────────────────┐
│              Advanced Agent Settings                        │
├─────────────────────────────────────────────────────────────┤
│ Environment Variables:                                      │
│ • JAVA_HOME=/usr/lib/jvm/java-11                           │
│ • PATH=/usr/local/bin:$PATH                                 │
│ • MAVEN_HOME=/opt/maven                                     │
│                                                             │
│ Tool Locations:                                             │
│ • Git: /usr/bin/git                                         │
│ • Maven: /opt/maven/bin/mvn                                 │
│ • Docker: /usr/bin/docker                                   │
│                                                             │
│ Node Properties:                                            │
│ • Workspace cleanup                                         │
│ • Build timeout                                             │
│ • Timestamper                                               │
│ • Environment injector                                      │
└─────────────────────────────────────────────────────────────┘
```

## Communication Protocols

### 1. JNLP (Java Network Launch Protocol)

#### Connection Process
```
┌─────────────────────────────────────────────────────────────┐
│                 JNLP Connection Flow                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ 1. Agent downloads agent.jar from master                    │
│         ↓                                                   │
│ 2. Agent establishes TCP connection                         │
│         ↓                                                   │
│ 3. Authentication and handshake                             │
│         ↓                                                   │
│ 4. Bidirectional communication channel                      │
│         ↓                                                   │
│ 5. Agent registers with master                              │
│                                                             │
│ Command Example:                                            │
│ java -jar agent.jar -jnlpUrl http://jenkins:8080/computer/agent1/slave-agent.jnlp -secret @secret-file │
└─────────────────────────────────────────────────────────────┘
```

#### JNLP Configuration
```
┌─────────────────────────────────────────────────────────────┐
│                JNLP Agent Setup                            │
├─────────────────────────────────────────────────────────────┤
│ Master Configuration:                                       │
│ • Enable JNLP port (default: 50000)                        │
│ • Configure security settings                               │
│ • Generate agent secret                                     │
│                                                             │
│ Agent Configuration:                                        │
│ • Download agent.jar                                        │
│ • Configure connection parameters                           │
│ • Set up as system service                                  │
│                                                             │
│ Firewall Requirements:                                      │
│ • Master: Port 8080 (HTTP) + 50000 (JNLP)                 │
│ • Agent: Outbound access to master                          │
└─────────────────────────────────────────────────────────────┘
```

### 2. SSH Connection

#### SSH Setup Process
```
┌─────────────────────────────────────────────────────────────┐
│                  SSH Agent Setup                           │
├─────────────────────────────────────────────────────────────┤
│ Prerequisites:                                              │
│ • SSH server running on agent machine                       │
│ • Java installed on agent                                   │
│ • SSH key pair generated                                    │
│                                                             │
│ Master Configuration:                                       │
│ 1. Add SSH credentials to Jenkins                           │
│ 2. Configure agent with SSH launch method                   │
│ 3. Specify host, port, and credentials                      │
│                                                             │
│ Agent Machine Setup:                                        │
│ 1. Create jenkins user                                      │
│ 2. Add master's public key to authorized_keys               │
│ 3. Ensure Java is in PATH                                   │
│                                                             │
│ Connection Command:                                         │
│ ssh -i ~/.ssh/jenkins_key jenkins@agent-host "java -jar ~/agent.jar" │
└─────────────────────────────────────────────────────────────┘
```

### 3. Windows Service Connection

#### Windows Agent Setup
```
┌─────────────────────────────────────────────────────────────┐
│               Windows Agent Configuration                   │
├─────────────────────────────────────────────────────────────┤
│ Installation Steps:                                         │
│ 1. Download and install Jenkins agent                       │
│ 2. Configure as Windows service                             │
│ 3. Set service account with appropriate permissions         │
│ 4. Configure firewall rules                                 │
│                                                             │
│ Service Configuration:                                      │
│ • Service Name: Jenkins Agent                               │
│ • Startup Type: Automatic                                   │
│ • Log On As: jenkins service account                        │
│ • Dependencies: None                                        │
│                                                             │
│ PowerShell Setup:                                           │
│ New-Service -Name "JenkinsAgent" -BinaryPathName "C:\jenkins\agent.exe" -StartupType Automatic │
└─────────────────────────────────────────────────────────────┘
```

## Load Distribution Strategies

### 1. Label-Based Distribution
```
┌─────────────────────────────────────────────────────────────┐
│                Label-Based Targeting                        │
├─────────────────────────────────────────────────────────────┤
│ Agent Labels:                                               │
│ • linux-build-01: linux, java, maven, docker               │
│ • windows-build-01: windows, dotnet, msbuild               │
│ • mac-build-01: macos, xcode, ios                          │
│                                                             │
│ Pipeline Usage:                                             │
│ pipeline {                                                  │
│     agent { label 'linux && docker' }                      │
│     stages {                                                │
│         stage('Build') {                                    │
│             steps {                                         │
│                 sh 'docker build -t myapp .'               │
│             }                                               │
│         }                                                   │
│     }                                                       │
│ }                                                           │
│                                                             │
│ Benefits:                                                   │
│ • Platform-specific builds                                  │
│ • Tool-specific targeting                                   │
│ • Resource optimization                                     │
└─────────────────────────────────────────────────────────────┘
```

### 2. Load Balancing Algorithms
```
┌─────────────────────────────────────────────────────────────┐
│               Load Balancing Methods                        │
├─────────────────────────────────────────────────────────────┤
│ 1. Fair Share:                                              │
│    • Distributes builds evenly across agents               │
│    • Considers executor availability                        │
│                                                             │
│ 2. Fastest First:                                           │
│    • Prioritizes agents with shortest queue                 │
│    • Optimizes for build completion time                    │
│                                                             │
│ 3. Label Preference:                                        │
│    • Uses specific agents for labeled jobs                  │
│    • Falls back to compatible agents                        │
│                                                             │
│ 4. Resource-Based:                                          │
│    • Considers CPU, memory, and disk usage                  │
│    • Prevents resource exhaustion                           │
└─────────────────────────────────────────────────────────────┘
```

## Agent Management Best Practices

### 1. Agent Monitoring
```
┌─────────────────────────────────────────────────────────────┐
│                 Agent Monitoring                           │
├─────────────────────────────────────────────────────────────┤
│ Health Checks:                                              │
│ • Connection status monitoring                              │
│ • Resource usage tracking                                   │
│ • Build success/failure rates                               │
│ • Response time measurements                                │
│                                                             │
│ Monitoring Tools:                                           │
│ • Jenkins built-in monitoring                               │
│ • Prometheus + Grafana                                      │
│ • Nagios/Zabbix integration                                 │
│ • Custom monitoring scripts                                 │
│                                                             │
│ Alert Conditions:                                           │
│ • Agent disconnection                                       │
│ • High resource usage                                       │
│ • Build queue backup                                        │
│ • Repeated build failures                                   │
└─────────────────────────────────────────────────────────────┘
```

### 2. Agent Maintenance
```
┌─────────────────────────────────────────────────────────────┐
│                Agent Maintenance Tasks                      │
├─────────────────────────────────────────────────────────────┤
│ Regular Tasks:                                              │
│ • Workspace cleanup                                         │
│ • Log rotation                                              │
│ • Temporary file cleanup                                    │
│ • System updates                                            │
│                                                             │
│ Automation Scripts:                                         │
│ #!/bin/bash                                                 │
│ # Agent cleanup script                                      │
│ find /home/jenkins/workspace -type d -mtime +7 -exec rm -rf {} \; │
│ find /tmp -name "jenkins*" -mtime +1 -delete               │
│ docker system prune -f                                      │
│                                                             │
│ Scheduled Maintenance:                                      │
│ • Weekly workspace cleanup                                  │
│ • Monthly system updates                                    │
│ • Quarterly capacity review                                 │
└─────────────────────────────────────────────────────────────┘
```

### 3. Security Considerations
```
┌─────────────────────────────────────────────────────────────┐
│                 Agent Security                             │
├─────────────────────────────────────────────────────────────┤
│ Network Security:                                           │
│ • Use VPN for remote agents                                 │
│ • Implement firewall rules                                  │
│ • Enable SSL/TLS encryption                                 │
│                                                             │
│ Access Control:                                             │
│ • Dedicated service accounts                                │
│ • Minimal required permissions                              │
│ • Regular credential rotation                               │
│                                                             │
│ Isolation:                                                  │
│ • Separate agents for different environments                │
│ • Container-based isolation                                 │
│ • Network segmentation                                      │
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting Common Issues

### Connection Problems
```
┌─────────────────────────────────────────────────────────────┐
│              Connection Troubleshooting                     │
├─────────────────────────────────────────────────────────────┤
│ JNLP Issues:                                                │
│ • Check JNLP port accessibility                             │
│ • Verify agent secret                                       │
│ • Review firewall settings                                  │
│ • Check Java version compatibility                          │
│                                                             │
│ SSH Issues:                                                 │
│ • Verify SSH key authentication                             │
│ • Check SSH service status                                  │
│ • Review SSH configuration                                  │
│ • Test manual SSH connection                                │
│                                                             │
│ Diagnostic Commands:                                        │
│ # Test JNLP connectivity                                    │
│ telnet jenkins-master 50000                                 │
│                                                             │
│ # Test SSH connectivity                                     │
│ ssh -v jenkins@agent-host                                   │
└─────────────────────────────────────────────────────────────┘
```

### Performance Issues
```
┌─────────────────────────────────────────────────────────────┐
│              Performance Troubleshooting                    │
├─────────────────────────────────────────────────────────────┤
│ Resource Monitoring:                                        │
│ # Check CPU usage                                           │
│ top -p $(pgrep java)                                        │
│                                                             │
│ # Check memory usage                                        │
│ free -h                                                     │
│ jstat -gc $(pgrep java)                                     │
│                                                             │
│ # Check disk usage                                          │
│ df -h                                                       │
│ du -sh /home/jenkins/workspace/*                            │
│                                                             │
│ Optimization Steps:                                         │
│ • Adjust executor count                                     │
│ • Increase JVM heap size                                    │
│ • Implement workspace cleanup                               │
│ • Use SSD storage                                           │
└─────────────────────────────────────────────────────────────┘
```

## Lab Exercises

### Exercise 1: Agent Setup
1. Configure a permanent Linux agent via SSH
2. Set up a Windows agent using JNLP
3. Create a Docker-based agent

### Exercise 2: Load Distribution
1. Configure agents with different labels
2. Create jobs targeting specific agents
3. Monitor load distribution

### Exercise 3: Agent Monitoring
1. Set up agent health monitoring
2. Create alerting for agent failures
3. Implement automated recovery

### Exercise 4: Performance Optimization
1. Analyze agent resource usage
2. Optimize executor configuration
3. Implement cleanup automation

## Key Takeaways

### Master Responsibilities
- Central coordination and management
- Job scheduling and queue management
- Plugin and security management
- User interface and API provision

### Agent Capabilities
- Distributed build execution
- Platform and tool diversity
- Scalable resource provision
- Isolated build environments

### Communication Excellence
- Multiple protocol support
- Secure encrypted connections
- Firewall-friendly options
- Reliable bidirectional communication

### Management Best Practices
- Proper labeling strategy
- Regular monitoring and maintenance
- Security-first approach
- Performance optimization focus