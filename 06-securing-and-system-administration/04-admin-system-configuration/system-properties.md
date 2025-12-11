# System Properties

## ⚙️ System Properties Overview

Jenkins system properties control various aspects of Jenkins behavior and can be set via JVM arguments, environment variables, or programmatically.

## 🚀 Setting System Properties

### **JVM Arguments**
```bash
# Set properties at startup
java -Dhudson.model.DirectoryBrowserSupport.CSP="default-src 'self'" \
     -Djenkins.install.runSetupWizard=false \
     -Dhudson.security.HudsonPrivateSecurityRealm.ID_REGEX="[a-zA-Z0-9_-]+" \
     -jar jenkins.war
```

### **Environment Variables**
```bash
# Set via environment (prefix with JAVA_OPTS)
export JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Dhudson.footerURL=http://company.com"

# Docker environment
docker run -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" jenkins/jenkins:lts
```

### **Programmatic Setting**
```groovy
// Set properties via Groovy script
System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "default-src 'self'")
System.setProperty("jenkins.model.Jenkins.crumbIssuerProxyCompatibility", "true")
System.setProperty("hudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION", "false")
```

## 🔒 Security Properties

### **Authentication & Authorization**
```bash
# User ID regex pattern
-Dhudson.security.HudsonPrivateSecurityRealm.ID_REGEX="[a-zA-Z0-9_-]+"

# Session timeout (seconds)
-Dhudson.security.SecurityRealm.sessionTimeout=1800

# CSRF protection
-Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=false

# API token security
-Djenkins.security.ApiTokenProperty.adminCanGenerateNewTokens=false
```

### **Content Security Policy**
```bash
# Strict CSP
-Dhudson.model.DirectoryBrowserSupport.CSP="default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"

# Disable CSP (not recommended)
-Dhudson.model.DirectoryBrowserSupport.CSP=""
```

### **CLI Security**
```bash
# Disable CLI over remoting
-Djenkins.CLI.disabled=true

# CLI port
-Dhudson.CLIConnectionFactory.port=50000
```

## 🛠️ Build & Job Properties

### **Build Configuration**
```bash
# Default build timeout (minutes)
-Dhudson.model.Build.timeout=60

# Workspace cleanup
-Dhudson.model.AbstractProject.workspaceCleanupRequired=true

# Build record retention
-Dhudson.model.Job.logRotatorNumToKeep=100
-Dhudson.model.Job.logRotatorDaysToKeep=30

# Quiet period
-Dhudson.model.AbstractProject.quietPeriod=5
```

### **SCM Properties**
```bash
# Git timeout (seconds)
-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=false
-Dhudson.plugins.git.GitSCM.timeout=600

# SVN timeout
-Dhudson.scm.SubversionSCM.timeout=3600

# Polling interval
-Dhudson.triggers.SCMTrigger.pollingThreadCount=10
```

### **Pipeline Properties**
```bash
# Pipeline durability
-Dorg.jenkinsci.plugins.workflow.flow.FlowExecutionList.LOAD_EXECUTIONS_ON_STARTUP=false

# Pipeline step timeout
-Dorg.jenkinsci.plugins.workflow.support.steps.build.RunWrapper.timeout=3600

# Groovy sandbox
-Dorg.jenkinsci.plugins.scriptsecurity.sandbox.groovy.GroovySandbox.ALLOW_ALL=false
```

## 🌐 Network & Performance Properties

### **HTTP Configuration**
```bash
# HTTP timeout
-Dhudson.model.UpdateCenter.connectionCheckTimeoutMillis=5000

# Proxy settings
-Dhttp.proxyHost=proxy.company.com
-Dhttp.proxyPort=8080
-Dhttps.proxyHost=proxy.company.com
-Dhttps.proxyPort=8080

# User agent
-Dhudson.model.UpdateCenter.userAgent="Jenkins/2.0 (Company CI/CD)"
```

### **Performance Tuning**
```bash
# JVM memory
-Xms2g -Xmx4g

# Garbage collection
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200

# Jenkins specific
-Dhudson.model.LoadStatistics.clock=5000
-Dhudson.model.LoadStatistics.decay=0.9
-Dhudson.slaves.NodeProvisioner.initialDelay=0
```

### **Agent Properties**
```bash
# Agent connection timeout
-Dhudson.slaves.ChannelPinger.pingTimeoutSeconds=240
-Dhudson.slaves.ChannelPinger.pingIntervalSeconds=300

# Agent retention
-Dhudson.slaves.WorkspaceList.retentionTime=86400

# JNLP agent
-Dhudson.slaves.JnlpSlaveAgentProtocol.enabled=false
-Dhudson.slaves.JnlpSlaveAgentProtocol2.enabled=false
-Dhudson.slaves.JnlpSlaveAgentProtocol3.enabled=false
-Dhudson.slaves.JnlpSlaveAgentProtocol4.enabled=true
```

## 📊 Logging Properties

### **Log Configuration**
```bash
# Log level
-Djava.util.logging.config.file=/var/lib/jenkins/logging.properties

# Specific logger levels
-Dhudson.security.level=FINE
-Dhudson.model.level=INFO
-Djenkins.security.level=WARNING
```

### **Audit Logging**
```bash
# Enable audit logging
-Dhudson.security.AuditTrail.enabled=true
-Dhudson.security.AuditTrail.logFile=/var/log/jenkins/audit.log

# Security event logging
-Djenkins.security.SecurityListener.logLevel=INFO
```

## 🔧 Plugin Properties

### **Plugin Management**
```bash
# Plugin installation
-Dhudson.PluginManager.workDir=/var/lib/jenkins/plugins
-Dhudson.PluginManager.noFastLookup=true

# Update center
-Dhudson.model.UpdateCenter.never=false
-Dhudson.model.DownloadService.noSignatureCheck=false

# Plugin loading
-Dhudson.PluginWrapper.dependenciesVersionCheck.enabled=true
```

### **Specific Plugin Properties**
```bash
# Git plugin
-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=false
-Dhudson.plugins.git.GitSCM.verbose=false

# Matrix authorization
-Dhudson.security.GlobalMatrixAuthorizationStrategy.allowAnonymousRead=false

# Build timeout
-Dhudson.plugins.build_timeout.BuildTimeoutWrapper.MINIMUM_TIMEOUT_MILLISECONDS=60000
```

## 🐳 Docker & Kubernetes Properties

### **Docker Properties**
```bash
# Docker plugin
-Dcom.github.dockerjava.core.DefaultDockerClientConfig.DOCKER_HOST=unix:///var/run/docker.sock
-Dcom.github.dockerjava.core.DefaultDockerClientConfig.DOCKER_TLS_VERIFY=false

# Docker build timeout
-Dorg.jenkinsci.plugins.docker.workflow.Docker.timeout=600
```

### **Kubernetes Properties**
```bash
# Kubernetes plugin
-Dorg.csanchez.jenkins.plugins.kubernetes.KubernetesCloud.connectionTimeout=30
-Dorg.csanchez.jenkins.plugins.kubernetes.KubernetesCloud.readTimeout=60

# Pod retention
-Dorg.csanchez.jenkins.plugins.kubernetes.PodTemplate.connectionTimeout=300
```

## 📝 Configuration Management

### **Properties File Management**
```groovy
// Load properties from file
def propsFile = new File('/var/lib/jenkins/jenkins.properties')
if (propsFile.exists()) {
    def props = new Properties()
    propsFile.withInputStream { props.load(it) }
    
    props.each { key, value ->
        System.setProperty(key.toString(), value.toString())
        println "Set property: ${key} = ${value}"
    }
}
```

### **Dynamic Property Updates**
```groovy
// Update properties at runtime
def updateProperty = { key, value ->
    def oldValue = System.getProperty(key)
    System.setProperty(key, value)
    
    println "Updated ${key}: ${oldValue} → ${value}"
    
    // Log property change
    def logger = Logger.getLogger("jenkins.system.properties")
    logger.info("Property updated: ${key} = ${value}")
}

updateProperty("hudson.model.DirectoryBrowserSupport.CSP", "default-src 'self'")
```

### **Properties Backup**
```groovy
// Backup current properties
def backupProperties = { ->
    def props = System.getProperties()
    def jenkinsProps = props.findAll { key, value ->
        key.toString().startsWith('hudson.') || 
        key.toString().startsWith('jenkins.') ||
        key.toString().startsWith('org.jenkinsci.')
    }
    
    def backup = new File('/var/lib/jenkins/properties-backup.txt')
    backup.withWriter { writer ->
        jenkinsProps.each { key, value ->
            writer.writeLine("${key}=${value}")
        }
    }
    
    println "Properties backed up to ${backup.absolutePath}"
}
```

## 🔍 Monitoring Properties

### **Property Inspection**
```groovy
// List all Jenkins-related properties
def listJenkinsProperties = { ->
    def props = System.getProperties()
    def jenkinsProps = props.findAll { key, value ->
        key.toString().contains('jenkins') || 
        key.toString().contains('hudson')
    }
    
    jenkinsProps.sort().each { key, value ->
        println "${key} = ${value}"
    }
}

listJenkinsProperties()
```

### **Property Validation**
```groovy
// Validate critical properties
def validateProperties = { ->
    def criticalProps = [
        'jenkins.install.runSetupWizard': 'false',
        'hudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION': 'false',
        'hudson.model.DirectoryBrowserSupport.CSP': { it != null && !it.isEmpty() }
    ]
    
    def issues = []
    
    criticalProps.each { prop, expected ->
        def actual = System.getProperty(prop)
        
        if (expected instanceof Closure) {
            if (!expected(actual)) {
                issues.add("Property ${prop} validation failed: ${actual}")
            }
        } else if (actual != expected) {
            issues.add("Property ${prop} mismatch: expected ${expected}, got ${actual}")
        }
    }
    
    return issues
}

def issues = validateProperties()
if (issues) {
    println "Property validation issues:"
    issues.each { println "- ${it}" }
}
```

## 📋 Common Property Sets

### **Production Environment**
```bash
# Production-ready properties
-Djenkins.install.runSetupWizard=false
-Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=false
-Dhudson.model.DirectoryBrowserSupport.CSP="default-src 'self'; script-src 'self' 'unsafe-inline'"
-Dhudson.security.HudsonPrivateSecurityRealm.ID_REGEX="[a-zA-Z0-9_-]+"
-Djenkins.CLI.disabled=true
-Dhudson.model.ParametersAction.keepUndefinedParameters=false
-Dhudson.model.UpdateCenter.never=false
```

### **Development Environment**
```bash
# Development-friendly properties
-Djenkins.install.runSetupWizard=false
-Dhudson.model.DirectoryBrowserSupport.CSP=""
-Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true
-Dhudson.model.UpdateCenter.never=true
-Djava.util.logging.ConsoleHandler.level=FINE
```

### **High-Performance Setup**
```bash
# Performance optimization
-Xms4g -Xmx8g
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-Dhudson.model.LoadStatistics.clock=1000
-Dhudson.slaves.NodeProvisioner.initialDelay=0
-Dhudson.slaves.NodeProvisioner.MARGIN=50
-Dhudson.slaves.NodeProvisioner.MARGIN0=0.85
```