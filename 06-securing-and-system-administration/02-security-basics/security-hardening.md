# Security Hardening

## 🔒 Security Hardening Overview

Jenkins security hardening involves implementing multiple layers of protection to secure your CI/CD infrastructure.

## 🛡️ System-Level Hardening

### **Operating System Security**
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Configure firewall
sudo ufw enable
sudo ufw allow 22/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 50000/tcp

# Disable unnecessary services
sudo systemctl disable apache2
sudo systemctl disable mysql
sudo systemctl stop unused-service
```

### **Jenkins User Security**
```bash
# Create dedicated Jenkins user
sudo useradd -r -m -s /bin/bash jenkins
sudo usermod -aG docker jenkins

# Set proper permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chmod 750 /var/lib/jenkins
sudo chmod 640 /var/lib/jenkins/config.xml
```

### **File System Security**
```bash
# Secure Jenkins home directory
sudo chmod 750 $JENKINS_HOME
sudo chmod 640 $JENKINS_HOME/config.xml
sudo chmod 600 $JENKINS_HOME/secrets/*

# Set up log rotation
sudo tee /etc/logrotate.d/jenkins << EOF
/var/log/jenkins/jenkins.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 jenkins jenkins
}
EOF
```

## 🔐 Jenkins Application Hardening

### **Security Configuration**
```groovy
import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.*

def instance = Jenkins.getInstance()

// Enable CSRF protection
instance.setCrumbIssuer(new DefaultCrumbIssuer(true))

// Disable CLI over remoting
instance.getDescriptor("jenkins.CLI").get().setEnabled(false)

// Configure agent protocols
Set<String> agentProtocols = ['JNLP4-connect', 'Ping']
instance.setAgentProtocols(agentProtocols)

// Disable usage statistics
instance.setNoUsageStatistics(true)

instance.save()
```

### **Disable Dangerous Features**
```groovy
// Disable script console for non-admins
import jenkins.model.Jenkins
import hudson.security.Permission

def jenkins = Jenkins.getInstance()
def descriptor = jenkins.getDescriptor("hudson.model.Hudson")
descriptor.setUsageStatisticsCollected(false)

// Disable build triggers from URL
System.setProperty("hudson.model.ParametersAction.keepUndefinedParameters", "false")
```

### **Secure Headers Configuration**
```groovy
// Configure security headers
System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", 
    "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'")

System.setProperty("jenkins.model.Jenkins.crumbIssuerProxyCompatibility", "false")
```

## 🔑 Authentication Hardening

### **Strong Password Policy**
```groovy
import hudson.security.*
import jenkins.model.*

// Configure password policy
def securityRealm = new HudsonPrivateSecurityRealm(false, false, null)
securityRealm.setPasswordPolicy(new PasswordPolicy() {
    @Override
    String validate(String password) {
        if (password.length() < 12) {
            return "Password must be at least 12 characters"
        }
        if (!password.matches(".*[A-Z].*")) {
            return "Password must contain uppercase letter"
        }
        if (!password.matches(".*[a-z].*")) {
            return "Password must contain lowercase letter"
        }
        if (!password.matches(".*[0-9].*")) {
            return "Password must contain number"
        }
        if (!password.matches(".*[!@#\$%^&*].*")) {
            return "Password must contain special character"
        }
        return null
    }
})

Jenkins.getInstance().setSecurityRealm(securityRealm)
```

### **Account Lockout Policy**
```groovy
// Implement account lockout
import hudson.security.*

def lockoutPolicy = new AccountLockoutPolicy()
lockoutPolicy.setMaxFailedAttempts(5)
lockoutPolicy.setLockoutDuration(300) // 5 minutes
lockoutPolicy.setEnabled(true)

Jenkins.getInstance().getExtensionList(SecurityListener.class)
    .add(new AccountLockoutSecurityListener(lockoutPolicy))
```

### **Session Security**
```groovy
// Configure session security
System.setProperty("hudson.security.HudsonPrivateSecurityRealm.ID_REGEX", "[a-zA-Z0-9_-]+")
System.setProperty("jenkins.security.seed", "random-seed-value")

// Session timeout (30 minutes)
System.setProperty("hudson.security.SecurityRealm.sessionTimeout", "1800")
```

## 🛡️ Network Security

### **Reverse Proxy Configuration (Nginx)**
```nginx
server {
    listen 443 ssl http2;
    server_name jenkins.company.com;
    
    ssl_certificate /etc/ssl/certs/jenkins.crt;
    ssl_certificate_key /etc/ssl/private/jenkins.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Security
        proxy_hide_header X-Powered-By;
        proxy_hide_header Server;
    }
}
```

### **Firewall Rules**
```bash
# iptables rules
sudo iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8080 -s 127.0.0.1 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 50000 -s 10.0.0.0/8 -j ACCEPT
sudo iptables -A INPUT -j DROP

# Save rules
sudo iptables-save > /etc/iptables/rules.v4
```

### **Network Segmentation**
```yaml
# Docker network isolation
version: '3.8'
services:
  jenkins:
    image: jenkins/jenkins:lts
    networks:
      - jenkins-internal
    ports:
      - "127.0.0.1:8080:8080"
      - "127.0.0.1:50000:50000"

networks:
  jenkins-internal:
    driver: bridge
    internal: true
```

## 🔒 Plugin Security

### **Plugin Management**
```groovy
// Disable plugin installation for non-admins
import jenkins.model.*
import hudson.security.*

def jenkins = Jenkins.getInstance()
def pluginManager = jenkins.getPluginManager()

// Restrict plugin installation
System.setProperty("hudson.PluginManager.workDir", "/var/lib/jenkins/plugins")
System.setProperty("hudson.PluginManager.noFastLookup", "true")
```

### **Plugin Whitelist**
```groovy
// Approved plugins list
def approvedPlugins = [
    'build-timeout',
    'credentials',
    'workflow-aggregator',
    'github',
    'ssh-slaves',
    'matrix-auth',
    'ldap'
]

def installedPlugins = Jenkins.instance.pluginManager.plugins
installedPlugins.each { plugin ->
    if (!approvedPlugins.contains(plugin.shortName)) {
        println "WARNING: Unapproved plugin detected: ${plugin.shortName}"
    }
}
```

### **Plugin Security Scanner**
```groovy
// Check for vulnerable plugins
import jenkins.model.*

def checkPluginSecurity = { ->
    def vulnerablePlugins = []
    def plugins = Jenkins.instance.pluginManager.plugins
    
    plugins.each { plugin ->
        // Check against known vulnerabilities
        if (isVulnerable(plugin)) {
            vulnerablePlugins.add([
                name: plugin.shortName,
                version: plugin.version,
                vulnerability: getVulnerabilityInfo(plugin)
            ])
        }
    }
    
    return vulnerablePlugins
}
```

## 🔐 Secrets Management

### **Credentials Security**
```groovy
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*

// Secure credential storage
def store = SystemCredentialsProvider.getInstance().getStore()
def domain = Domain.global()

// Use encrypted credentials
def secretText = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    "secret-id",
    "Secret description",
    Secret.fromString("encrypted-secret-value")
)

store.addCredentials(domain, secretText)
```

### **External Secrets Integration**
```groovy
// HashiCorp Vault integration
import com.datapipe.jenkins.vault.*

def vaultConfig = new VaultConfiguration()
vaultConfig.setVaultUrl("https://vault.company.com")
vaultConfig.setVaultNamespace("jenkins")

// AWS Secrets Manager
def awsCredentials = new AWSCredentialsImpl(
    CredentialsScope.GLOBAL,
    "aws-secrets",
    "AWS Secrets Manager",
    "access-key",
    "secret-key"
)
```

## 🔍 Security Monitoring

### **Audit Logging**
```groovy
import jenkins.security.*
import hudson.model.*

// Enable audit logging
def auditLogger = Logger.getLogger("jenkins.security.audit")
auditLogger.setLevel(Level.INFO)

// Custom security listener
SecurityListener.all().add(new SecurityListener() {
    @Override
    void authenticated(UserDetails details) {
        auditLogger.info("User authenticated: ${details.username}")
    }
    
    @Override
    void failedToAuthenticate(String username) {
        auditLogger.warning("Failed authentication: ${username}")
    }
    
    @Override
    void loggedOut(String username) {
        auditLogger.info("User logged out: ${username}")
    }
})
```

### **Security Scanning Script**
```groovy
// Security health check
def securityCheck = { ->
    def issues = []
    
    // Check CSRF protection
    if (!Jenkins.instance.crumbIssuer) {
        issues.add("CSRF protection disabled")
    }
    
    // Check CLI security
    if (Jenkins.instance.getDescriptor("jenkins.CLI").get().enabled) {
        issues.add("CLI over remoting enabled")
    }
    
    // Check agent protocols
    def protocols = Jenkins.instance.agentProtocols
    if (protocols.contains('JNLP-connect') || protocols.contains('JNLP2-connect')) {
        issues.add("Insecure agent protocols enabled")
    }
    
    return issues
}

def issues = securityCheck()
if (issues) {
    println "Security issues found:"
    issues.each { println "- ${it}" }
} else {
    println "No security issues detected"
}
```

## 📋 Security Checklist

### **Basic Security**
- [ ] Enable CSRF protection
- [ ] Disable CLI over remoting
- [ ] Use secure agent protocols
- [ ] Configure strong authentication
- [ ] Implement authorization strategy
- [ ] Regular security updates

### **Advanced Security**
- [ ] Network segmentation
- [ ] Reverse proxy with SSL
- [ ] Security headers configuration
- [ ] Plugin security review
- [ ] Secrets management
- [ ] Audit logging
- [ ] Security monitoring
- [ ] Regular security assessments