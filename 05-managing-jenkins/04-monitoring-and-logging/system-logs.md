# System Logs

## 📋 Jenkins Logging Overview

Jenkins generates various types of logs that are essential for monitoring, troubleshooting, and maintaining the system.

## 📍 Log Locations

### **Default Log Locations**

#### **Linux/Unix**
```bash
# Jenkins home directory logs
/var/lib/jenkins/logs/

# System service logs
/var/log/jenkins/jenkins.log
journalctl -u jenkins

# Web container logs (if using Tomcat)
/var/log/tomcat/catalina.out
```

#### **Windows**
```cmd
# Jenkins home directory
C:\ProgramData\Jenkins\logs\

# Windows Event Log
Event Viewer → Windows Logs → Application
```

#### **Docker**
```bash
# Container logs
docker logs jenkins-container

# Mounted volume logs
/var/jenkins_home/logs/
```

## 🔍 Log Types

### **1. Jenkins System Log**
Main Jenkins application log containing startup, shutdown, and system events.

```bash
# View current log
tail -f /var/log/jenkins/jenkins.log

# Search for errors
grep -i error /var/log/jenkins/jenkins.log

# Filter by date
grep "2024-01-15" /var/log/jenkins/jenkins.log
```

### **2. Build Logs**
Individual job execution logs stored per build.

```bash
# Build log location
/var/lib/jenkins/jobs/[JOB_NAME]/builds/[BUILD_NUMBER]/log

# View specific build log
cat /var/lib/jenkins/jobs/my-project/builds/42/log

# Search across all build logs
find /var/lib/jenkins/jobs -name "log" -exec grep -l "ERROR" {} \;
```

### **3. Agent Logs**
Logs from Jenkins agents/slaves.

```bash
# Agent connection logs
/var/lib/jenkins/logs/slaves/[AGENT_NAME]/

# Agent launcher logs
tail -f /var/lib/jenkins/logs/slaves/linux-agent-01/slave.log
```

### **4. Plugin Logs**
Logs specific to installed plugins.

```bash
# Plugin-specific logs
/var/lib/jenkins/logs/plugins/

# Example: Git plugin logs
tail -f /var/lib/jenkins/logs/plugins/git.log
```

## 🔧 Log Configuration

### **Logging Configuration File**
```xml
<!-- /var/lib/jenkins/log.properties -->
handlers= java.util.logging.ConsoleHandler
.level= INFO

# Jenkins core logging
jenkins.level = INFO
hudson.level = INFO

# Plugin logging levels
hudson.plugins.git.level = FINE
org.jenkinsci.plugins.workflow.level = FINE

# Security logging
hudson.security.level = WARNING
jenkins.security.level = WARNING

# Performance logging
jenkins.model.Jenkins.level = INFO
hudson.model.AbstractBuild.level = INFO
```

### **System Property Configuration**
```bash
# Set logging level via system property
java -Djava.util.logging.config.file=/var/lib/jenkins/log.properties \
     -Djenkins.install.runSetupWizard=false \
     -jar jenkins.war
```

### **Programmatic Log Configuration**
```groovy
// Configure logging via Groovy script
import java.util.logging.*

// Set root logger level
Logger.getLogger("").setLevel(Level.INFO)

// Configure specific loggers
Logger.getLogger("hudson.security").setLevel(Level.WARNING)
Logger.getLogger("jenkins.security").setLevel(Level.WARNING)
Logger.getLogger("hudson.plugins.git").setLevel(Level.FINE)

// Add custom handler
def handler = new FileHandler("/var/lib/jenkins/logs/custom.log")
handler.setFormatter(new SimpleFormatter())
Logger.getLogger("jenkins.custom").addHandler(handler)
```

## 📊 Log Management

### **Log Rotation Configuration**
```bash
# /etc/logrotate.d/jenkins
/var/log/jenkins/jenkins.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 0644 jenkins jenkins
    postrotate
        systemctl reload jenkins || true
    endscript
}
```

### **Automated Log Cleanup**
```bash
#!/bin/bash
# cleanup-jenkins-logs.sh

JENKINS_HOME="/var/lib/jenkins"
DAYS_TO_KEEP=30

# Clean old build logs
find $JENKINS_HOME/jobs/*/builds/*/log -mtime +$DAYS_TO_KEEP -delete

# Clean old workspace files
find $JENKINS_HOME/workspace -type f -mtime +$DAYS_TO_KEEP -delete

# Clean temporary files
find $JENKINS_HOME/tmp -type f -mtime +7 -delete

# Compress old logs
find $JENKINS_HOME/logs -name "*.log" -mtime +7 -exec gzip {} \;

echo "Log cleanup completed: $(date)"
```

### **Log Size Monitoring**
```bash
#!/bin/bash
# monitor-log-sizes.sh

JENKINS_HOME="/var/lib/jenkins"
MAX_SIZE_MB=100

# Check main log size
MAIN_LOG_SIZE=$(du -m /var/log/jenkins/jenkins.log | cut -f1)
if [ $MAIN_LOG_SIZE -gt $MAX_SIZE_MB ]; then
    echo "WARNING: Main log size is ${MAIN_LOG_SIZE}MB"
fi

# Check build log sizes
find $JENKINS_HOME/jobs -name "log" -size +${MAX_SIZE_MB}M -exec ls -lh {} \;

# Check total log directory size
TOTAL_SIZE=$(du -sh $JENKINS_HOME/logs | cut -f1)
echo "Total logs size: $TOTAL_SIZE"
```

## 🔍 Log Analysis

### **Common Log Patterns**

#### **Startup/Shutdown Events**
```bash
# Jenkins startup
grep "Jenkins is fully up and running" /var/log/jenkins/jenkins.log

# Plugin loading
grep "Loading plugin" /var/log/jenkins/jenkins.log

# Shutdown events
grep "Terminating" /var/log/jenkins/jenkins.log
```

#### **Security Events**
```bash
# Failed login attempts
grep "Failed to authenticate" /var/log/jenkins/jenkins.log

# Permission denied
grep "Permission denied" /var/log/jenkins/jenkins.log

# User creation/deletion
grep -E "(User|Account)" /var/log/jenkins/jenkins.log
```

#### **Build Events**
```bash
# Build started
grep "Started by" /var/lib/jenkins/jobs/*/builds/*/log

# Build failures
grep -i "build failed" /var/lib/jenkins/jobs/*/builds/*/log

# SCM polling
grep "SCM polling" /var/log/jenkins/jenkins.log
```

### **Log Analysis Scripts**
```bash
#!/bin/bash
# analyze-jenkins-logs.sh

LOG_FILE="/var/log/jenkins/jenkins.log"
TODAY=$(date +%Y-%m-%d)

echo "=== Jenkins Log Analysis for $TODAY ==="

# Count log levels
echo "Log Level Summary:"
grep "$TODAY" $LOG_FILE | cut -d' ' -f3 | sort | uniq -c | sort -nr

# Top errors
echo -e "\nTop Errors:"
grep "$TODAY.*ERROR" $LOG_FILE | cut -d']' -f2- | sort | uniq -c | sort -nr | head -10

# Plugin issues
echo -e "\nPlugin Issues:"
grep "$TODAY.*plugin" $LOG_FILE | grep -i error

# Memory warnings
echo -e "\nMemory Warnings:"
grep "$TODAY.*memory\|OutOfMemory" $LOG_FILE

# Security events
echo -e "\nSecurity Events:"
grep "$TODAY.*security\|authentication\|authorization" $LOG_FILE
```

## 📈 Log Monitoring Tools

### **ELK Stack Integration**
```yaml
# filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/jenkins/jenkins.log
    - /var/lib/jenkins/jobs/*/builds/*/log
  fields:
    service: jenkins
    environment: production
  multiline.pattern: '^\d{4}-\d{2}-\d{2}'
  multiline.negate: true
  multiline.match: after

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "jenkins-logs-%{+yyyy.MM.dd}"

processors:
- add_host_metadata:
    when.not.contains.tags: forwarded
```

### **Prometheus Metrics from Logs**
```bash
#!/bin/bash
# jenkins-log-metrics.sh

LOG_FILE="/var/log/jenkins/jenkins.log"
METRICS_FILE="/var/lib/node_exporter/textfile_collector/jenkins.prom"

# Count errors in last hour
ERROR_COUNT=$(grep "$(date -d '1 hour ago' '+%Y-%m-%d %H').*ERROR" $LOG_FILE | wc -l)

# Count warnings
WARNING_COUNT=$(grep "$(date -d '1 hour ago' '+%Y-%m-%d %H').*WARNING" $LOG_FILE | wc -l)

# Generate Prometheus metrics
cat > $METRICS_FILE << EOF
# HELP jenkins_log_errors_total Total number of errors in Jenkins logs
# TYPE jenkins_log_errors_total counter
jenkins_log_errors_total $ERROR_COUNT

# HELP jenkins_log_warnings_total Total number of warnings in Jenkins logs
# TYPE jenkins_log_warnings_total counter
jenkins_log_warnings_total $WARNING_COUNT
EOF
```

### **Splunk Integration**
```bash
# inputs.conf
[monitor:///var/log/jenkins/jenkins.log]
disabled = false
index = jenkins
sourcetype = jenkins:system

[monitor:///var/lib/jenkins/jobs/.../builds/.../log]
disabled = false
index = jenkins
sourcetype = jenkins:build
```

## 🚨 Log Alerting

### **Error Detection Script**
```bash
#!/bin/bash
# jenkins-error-alert.sh

LOG_FILE="/var/log/jenkins/jenkins.log"
ALERT_EMAIL="admin@company.com"
LAST_CHECK_FILE="/tmp/jenkins_last_check"

# Get timestamp of last check
if [ -f $LAST_CHECK_FILE ]; then
    LAST_CHECK=$(cat $LAST_CHECK_FILE)
else
    LAST_CHECK=$(date -d '1 hour ago' '+%Y-%m-%d %H:%M:%S')
fi

# Find new errors since last check
NEW_ERRORS=$(awk -v start="$LAST_CHECK" '$0 > start && /ERROR/' $LOG_FILE)

if [ ! -z "$NEW_ERRORS" ]; then
    echo "New Jenkins errors detected:" | mail -s "Jenkins Alert" $ALERT_EMAIL
    echo "$NEW_ERRORS" | mail -s "Jenkins Error Details" $ALERT_EMAIL
fi

# Update last check timestamp
date '+%Y-%m-%d %H:%M:%S' > $LAST_CHECK_FILE
```

### **Slack Integration**
```bash
#!/bin/bash
# slack-jenkins-alerts.sh

SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
LOG_FILE="/var/log/jenkins/jenkins.log"

# Check for critical errors
CRITICAL_ERRORS=$(grep "$(date '+%Y-%m-%d %H').*SEVERE\|FATAL" $LOG_FILE)

if [ ! -z "$CRITICAL_ERRORS" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"🚨 Jenkins Critical Error Detected:\n\`\`\`$CRITICAL_ERRORS\`\`\`\"}" \
        $SLACK_WEBHOOK
fi
```

## 🔧 Advanced Logging

### **Custom Log Appenders**
```groovy
// Add custom log appender
import java.util.logging.*
import jenkins.model.*

// Create custom formatter
class CustomFormatter extends Formatter {
    @Override
    String format(LogRecord record) {
        return "${new Date(record.millis)} [${record.level}] ${record.loggerName}: ${record.message}\n"
    }
}

// Add file handler with custom formatter
def logger = Logger.getLogger("jenkins.custom")
def handler = new FileHandler("/var/lib/jenkins/logs/custom-app.log", true)
handler.setFormatter(new CustomFormatter())
logger.addHandler(handler)
logger.setLevel(Level.INFO)

// Test logging
logger.info("Custom logging initialized")
```

### **Structured Logging**
```groovy
// JSON structured logging
import groovy.json.JsonBuilder
import java.util.logging.*

class JsonFormatter extends Formatter {
    @Override
    String format(LogRecord record) {
        def json = new JsonBuilder([
            timestamp: new Date(record.millis).format("yyyy-MM-dd'T'HH:mm:ss.SSSZ"),
            level: record.level.toString(),
            logger: record.loggerName,
            message: record.message,
            thread: Thread.currentThread().name
        ])
        return json.toString() + "\n"
    }
}

// Apply JSON formatter
def logger = Logger.getLogger("jenkins.structured")
def handler = new FileHandler("/var/lib/jenkins/logs/structured.log", true)
handler.setFormatter(new JsonFormatter())
logger.addHandler(handler)
```

## 💡 Best Practices

### **1. Log Levels**
```
SEVERE/FATAL: System failures, critical errors
WARNING: Potential issues, deprecated features
INFO: General information, startup/shutdown
FINE/DEBUG: Detailed debugging information
FINEST/TRACE: Very detailed debugging
```

### **2. Log Retention**
```
System logs: 30-90 days
Build logs: 30 days or last 100 builds
Debug logs: 7 days
Audit logs: 1 year or per compliance requirements
```

### **3. Performance Considerations**
```
- Use appropriate log levels in production
- Implement log rotation
- Monitor log file sizes
- Use asynchronous logging for high-volume logs
```

### **4. Security**
```
- Avoid logging sensitive information
- Secure log file permissions
- Implement log integrity checks
- Regular log analysis for security events
```