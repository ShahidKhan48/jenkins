# Troubleshooting Guide

## 🔧 Troubleshooting Overview

This comprehensive troubleshooting guide covers common Jenkins issues, their root causes, and step-by-step solutions for maintaining a healthy CI/CD environment.

## 📚 Learning Path

### **🔰 Beginner Level**
1. **Basic Connectivity** → Master-agent connection issues
2. **SCM Problems** → Git authentication and repository access
3. **Build Failures** → Pipeline syntax and execution errors

### **🔥 Intermediate Level**
4. **Container Issues** → Docker registry and image problems
5. **Orchestration** → Kubernetes deployment and pod failures
6. **Pipeline Debugging** → Jenkinsfile errors and debugging

### **🚀 Advanced Level**
7. **Security Issues** → Security scanning and compliance problems
8. **Credential Management** → Authentication and authorization issues
9. **Plugin Problems** → Plugin conflicts and compatibility issues

## 🎯 Quick Diagnostic Guide

### **System Health Check (5 minutes)**
```bash
# Check Jenkins service status
systemctl status jenkins

# Check disk space
df -h /var/lib/jenkins

# Check memory usage
free -h

# Check recent logs
tail -n 50 /var/log/jenkins/jenkins.log
```

### **Network Connectivity Test**
```bash
# Test agent connectivity
nc -zv agent-host 22

# Test Git repository access
git ls-remote https://github.com/user/repo.git

# Test Docker registry
curl -v https://registry.company.com/v2/
```

### **Quick Fix Commands**
```groovy
// Restart offline agents
Jenkins.instance.computers.findAll { it.isOffline() }.each { 
    it.connect(true) 
}

// Clear build queue
Jenkins.instance.queue.clear()

// Reload configuration
Jenkins.instance.reload()
```

## 📖 Section Contents

### **01. Master-Agent Issues**
- **[Agent Offline](01-master-agent-issues/1-agent-offline.md)** → Basic agent connectivity problems
- **[Connection Problems](01-master-agent-issues/connection-problems.md)** → Network, SSH, and JNLP issues

### **02. Git SCM Issues**
- **[Git Authentication](02-git-scm-issues/git-authentication.md)** → SSH keys, tokens, and credential management

### **03. Pipeline Build Failures**
- **[Syntax Errors](03-pipeline-build-failures/syntax-errors.md)** → Jenkinsfile syntax validation and debugging

### **04. Docker Push Issues**
- **[Registry Authentication](04-docker-push-issues/registry-authentication.md)** → Docker Hub, private registries, and cloud authentication

### **05. Kubernetes Deployment Issues**
- **[Pod Failures](05-kubernetes-deployment-issues/pod-failures.md)** → Pod startup, resource, and networking issues

### **06. Jenkinsfile Errors**
- **Pipeline Debugging** → Advanced pipeline troubleshooting techniques
- **Shared Library Issues** → Library loading and execution problems

### **07. Security Scanning Issues**
- **SAST/DAST Problems** → Security tool integration issues
- **Compliance Failures** → Policy and compliance scanning problems

### **08. Credentials Issues**
- **Credential Store Problems** → Credential access and management
- **Secret Management** → External secret integration issues

### **09. Plugin Problems**
- **Plugin Conflicts** → Version compatibility and dependency issues
- **Performance Issues** → Plugin-related performance problems

## 🚨 Emergency Response Procedures

### **Service Down (Critical)**
```bash
# 1. Check service status
systemctl status jenkins

# 2. Check system resources
top
df -h

# 3. Check logs for errors
journalctl -u jenkins -f

# 4. Restart service if needed
systemctl restart jenkins

# 5. Verify service recovery
curl -I http://jenkins:8080
```

### **Build Queue Stuck**
```groovy
// Clear stuck builds
Jenkins.instance.queue.items.each { item ->
    if (item.inQueueForMillis > 300000) { // 5 minutes
        Jenkins.instance.queue.cancel(item)
    }
}

// Restart executors
Jenkins.instance.computers.each { computer ->
    computer.executors.each { executor ->
        if (executor.isBusy()) {
            executor.interrupt()
        }
    }
}
```

### **Disk Space Critical**
```bash
# Clean old builds
find /var/lib/jenkins/jobs/*/builds -type d -mtime +30 -exec rm -rf {} +

# Clean workspace
find /var/lib/jenkins/workspace -type d -mtime +7 -exec rm -rf {} +

# Clean logs
find /var/log/jenkins -name "*.log" -mtime +7 -delete
```

## 🔍 Diagnostic Tools

### **Log Analysis Commands**
```bash
# Search for errors in Jenkins logs
grep -i "error\|exception\|failed" /var/log/jenkins/jenkins.log

# Monitor logs in real-time
tail -f /var/log/jenkins/jenkins.log | grep -E "(ERROR|SEVERE|WARNING)"

# Analyze build logs
find /var/lib/jenkins/jobs -name "log" -exec grep -l "BUILD FAILED" {} \;
```

### **System Monitoring**
```bash
# Monitor system resources
htop
iotop
nethogs

# Check Java processes
jps -v
jstat -gc <jenkins-pid>

# Monitor network connections
netstat -tulpn | grep :8080
ss -tulpn | grep :50000
```

### **Jenkins Health Checks**
```groovy
// System health check script
def healthCheck = [:]

// Check disk space
def jenkinsHome = new File(System.getProperty("JENKINS_HOME"))
def freeSpace = jenkinsHome.getFreeSpace()
def totalSpace = jenkinsHome.getTotalSpace()
healthCheck.diskUsage = ((totalSpace - freeSpace) / totalSpace * 100).round(2)

// Check memory usage
def runtime = Runtime.getRuntime()
def maxMemory = runtime.maxMemory()
def totalMemory = runtime.totalMemory()
def freeMemory = runtime.freeMemory()
healthCheck.memoryUsage = ((totalMemory - freeMemory) / maxMemory * 100).round(2)

// Check agent status
def offlineAgents = Jenkins.instance.computers.findAll { it.isOffline() }
healthCheck.offlineAgents = offlineAgents.size()

// Check build queue
healthCheck.queueSize = Jenkins.instance.queue.items.size()

println "Health Check Results:"
healthCheck.each { key, value ->
    println "${key}: ${value}"
}
```

## 🛠️ Common Problem Patterns

### **Performance Issues**
```bash
# Symptoms
- Slow web interface response
- Build queue backing up
- High CPU/memory usage
- Timeouts and connection errors

# Quick fixes
- Increase JVM heap size: -Xmx4g
- Reduce concurrent builds
- Clean up old builds and workspaces
- Restart Jenkins service
```

### **Authentication Problems**
```bash
# Symptoms
- Login failures
- Permission denied errors
- LDAP/SSO integration issues
- API authentication failures

# Quick fixes
- Check credential configuration
- Verify LDAP/SSO connectivity
- Reset user passwords
- Check security realm settings
```

### **Plugin Issues**
```bash
# Symptoms
- Plugin loading failures
- Compatibility errors
- Missing functionality
- Performance degradation

# Quick fixes
- Update plugins to latest versions
- Check plugin dependencies
- Disable problematic plugins
- Clear plugin cache
```

## 📊 Monitoring and Alerting

### **Key Metrics to Monitor**
```yaml
# Prometheus monitoring rules
groups:
- name: jenkins-health
  rules:
  - alert: JenkinsDown
    expr: up{job="jenkins"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Jenkins is down"
  
  - alert: JenkinsHighMemoryUsage
    expr: jenkins_memory_usage_percent > 85
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Jenkins memory usage is high"
  
  - alert: JenkinsBuildQueueHigh
    expr: jenkins_queue_size > 10
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "Jenkins build queue is backing up"
```

### **Health Dashboard**
```groovy
// Create health dashboard data
def createHealthDashboard() {
    def dashboard = [:]
    
    // System metrics
    dashboard.system = [
        uptime: ManagementFactory.getRuntimeMXBean().getUptime(),
        version: Jenkins.getVersion(),
        javaVersion: System.getProperty("java.version")
    ]
    
    // Build metrics
    dashboard.builds = [
        queueSize: Jenkins.instance.queue.items.size(),
        runningBuilds: Jenkins.instance.computers.sum { it.executors.count { it.isBusy() } },
        totalExecutors: Jenkins.instance.computers.sum { it.numExecutors }
    ]
    
    // Agent metrics
    dashboard.agents = [
        total: Jenkins.instance.computers.size() - 1, // Exclude master
        online: Jenkins.instance.computers.count { !it.isOffline() } - 1,
        offline: Jenkins.instance.computers.count { it.isOffline() }
    ]
    
    return dashboard
}

def dashboard = createHealthDashboard()
println groovy.json.JsonBuilder(dashboard).toPrettyString()
```

## 🔧 Maintenance Scripts

### **Daily Maintenance**
```bash
#!/bin/bash
# daily-maintenance.sh

# Check disk space
DISK_USAGE=$(df /var/lib/jenkins | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "WARNING: Disk usage is ${DISK_USAGE}%"
    # Clean old builds
    find /var/lib/jenkins/jobs/*/builds -mtime +30 -type d -exec rm -rf {} +
fi

# Check service status
if ! systemctl is-active --quiet jenkins; then
    echo "ERROR: Jenkins service is not running"
    systemctl restart jenkins
fi

# Backup configuration
tar -czf /backup/jenkins-config-$(date +%Y%m%d).tar.gz \
    /var/lib/jenkins/config.xml \
    /var/lib/jenkins/jobs/*/config.xml
```

### **Weekly Health Check**
```groovy
// weekly-health-check.groovy
def performHealthCheck() {
    def issues = []
    
    // Check for failed jobs
    def failedJobs = Jenkins.instance.getAllItems(Job.class).findAll { 
        it.getLastBuild()?.getResult() == Result.FAILURE 
    }
    if (failedJobs.size() > 5) {
        issues.add("High number of failed jobs: ${failedJobs.size()}")
    }
    
    // Check for offline agents
    def offlineAgents = Jenkins.instance.computers.findAll { it.isOffline() }
    if (offlineAgents.size() > 0) {
        issues.add("Offline agents detected: ${offlineAgents.collect { it.name }}")
    }
    
    // Check plugin updates
    def outdatedPlugins = Jenkins.instance.pluginManager.plugins.findAll { 
        it.hasUpdate() 
    }
    if (outdatedPlugins.size() > 10) {
        issues.add("Many outdated plugins: ${outdatedPlugins.size()}")
    }
    
    return issues
}

def issues = performHealthCheck()
if (issues) {
    println "Health check issues found:"
    issues.each { println "- ${it}" }
} else {
    println "All health checks passed"
}
```

## 📋 Troubleshooting Methodology

### **Problem Identification**
1. **Gather Information**
   - What is the exact error message?
   - When did the problem start?
   - What changed recently?
   - Is it affecting all users or specific ones?

2. **Check System Health**
   - Service status and logs
   - System resources (CPU, memory, disk)
   - Network connectivity
   - Recent configuration changes

3. **Isolate the Problem**
   - Test with minimal configuration
   - Disable non-essential plugins
   - Use different agents/environments
   - Check with different users/permissions

### **Solution Implementation**
1. **Start with Simple Fixes**
   - Restart services
   - Clear caches
   - Update configurations
   - Check permissions

2. **Apply Systematic Changes**
   - Make one change at a time
   - Test after each change
   - Document what was tried
   - Keep backups of configurations

3. **Verify the Solution**
   - Test the specific problem scenario
   - Check for side effects
   - Monitor for recurrence
   - Update documentation

## 📚 Additional Resources

### **Documentation Links**
- [Jenkins Troubleshooting Guide](https://www.jenkins.io/doc/book/system-administration/troubleshooting/)
- [Jenkins System Information](https://www.jenkins.io/doc/book/managing/system-information/)
- [Jenkins Logging](https://www.jenkins.io/doc/book/system-administration/viewing-logs/)

### **Community Resources**
- Jenkins User Mailing List
- Stack Overflow Jenkins Tag
- Jenkins Community Forums
- GitHub Issues for Plugins

### **Monitoring Tools**
- **Prometheus + Grafana**: Metrics and dashboards
- **ELK Stack**: Log aggregation and analysis
- **Nagios/Zabbix**: System monitoring
- **Jenkins Monitoring Plugin**: Built-in monitoring

---

**Remember**: Always backup configurations before making changes, and test solutions in a non-production environment when possible.