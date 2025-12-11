# Configuring the System

## 🔧 System Configuration Overview

Jenkins system configuration is accessed through **Manage Jenkins → Configure System** and controls global settings that affect the entire Jenkins instance.

## 🏠 Jenkins Location

### **Jenkins URL**
```
Jenkins URL: http://jenkins.company.com:8080/
```
- Used for email notifications
- Required for webhooks
- Affects build URLs in notifications

### **System Admin Email**
```
System Admin e-mail address: admin@company.com
```
- Default sender for email notifications
- Used in error messages
- Contact information for users

## 📧 Email Configuration

### **SMTP Server Setup**
```
SMTP server: smtp.gmail.com
Default user e-mail suffix: @company.com
Use SMTP Authentication: ✓
User Name: jenkins@company.com
Password: [app-password]
Use SSL: ✓
SMTP Port: 465
```

### **Test Email Configuration**
```groovy
// Test email in Jenkins Script Console
import javax.mail.*
import javax.mail.internet.*

def msg = new MimeMessage(session)
msg.setFrom(new InternetAddress("jenkins@company.com"))
msg.setRecipients(Message.RecipientType.TO, "admin@company.com")
msg.setSubject("Jenkins Test Email")
msg.setText("This is a test email from Jenkins")
Transport.send(msg)
```

## 🔐 Security Configuration

### **Global Security Settings**
- Enable security: ✓
- Security Realm: Jenkins' own user database
- Authorization: Matrix-based security

### **CSRF Protection**
```
Enable CSRF Protection: ✓
Default Crumb Issuer: ✓
```

### **Agent Protocols**
```
Enabled protocols:
- JNLP4-connect
- JNLP4-plaintext (for troubleshooting only)
```

## 🛠️ Build Configuration

### **Global Properties**
```groovy
// Environment variables
JAVA_HOME=/usr/lib/jvm/java-11-openjdk
MAVEN_HOME=/opt/maven
PATH+EXTRA=/opt/custom/bin
```

### **Build Record Length**
```
# of builds to keep: 100
# of days to keep builds: 30
```

### **Quiet Period**
```
Quiet period: 5 seconds
```
- Prevents multiple builds from same trigger
- Useful for rapid commits

## 📊 Resource Management

### **Executors**
```
# of executors: 4
```
- Number of concurrent builds on master
- Should match CPU cores
- Consider using agents instead

### **Usage Statistics**
```
Help make Jenkins better by sending anonymous usage statistics: ✓
```

## 🔧 Advanced Configuration

### **Jenkins CLI**
```groovy
// Enable CLI over remoting
Jenkins CLI: Enabled
CLI port: 50000
```

### **Markup Formatter**
```
Markup Formatter: Safe HTML
```
- Prevents XSS attacks
- Allows basic HTML formatting

### **Shell Executable**
```
Shell executable: /bin/bash
```
- Default shell for shell build steps
- Platform-specific setting

## 📝 Configuration as Code (JCasC)

### **YAML Configuration Example**
```yaml
jenkins:
  systemMessage: "Jenkins configured automatically by JCasC"
  numExecutors: 2
  mode: NORMAL
  
  globalNodeProperties:
    - envVars:
        env:
          - key: "JAVA_HOME"
            value: "/usr/lib/jvm/java-11-openjdk"
          - key: "MAVEN_HOME"
            value: "/opt/maven"

unclassified:
  location:
    url: "http://jenkins.company.com:8080/"
    adminAddress: "admin@company.com"
    
  mailer:
    smtpHost: "smtp.gmail.com"
    smtpPort: 465
    useSsl: true
    authentication:
      username: "jenkins@company.com"
      password: "${SMTP_PASSWORD}"
```

### **Loading JCasC Configuration**
```bash
# Set environment variable
export CASC_JENKINS_CONFIG=/var/jenkins_home/casc.yaml

# Or use system property
java -Dcasc.jenkins.config=/var/jenkins_home/casc.yaml -jar jenkins.war
```

## 🔍 Monitoring System Configuration

### **System Information**
```groovy
// Get system info via Groovy script
println "Jenkins Version: " + Jenkins.instance.getVersion()
println "Java Version: " + System.getProperty("java.version")
println "OS: " + System.getProperty("os.name")
println "Available Processors: " + Runtime.getRuntime().availableProcessors()
println "Max Memory: " + Runtime.getRuntime().maxMemory() / 1024 / 1024 + " MB"
```

### **Configuration Backup**
```bash
# Backup Jenkins configuration
tar -czf jenkins-config-$(date +%Y%m%d).tar.gz \
  $JENKINS_HOME/config.xml \
  $JENKINS_HOME/jobs/*/config.xml \
  $JENKINS_HOME/users/*/config.xml
```

## ⚠️ Common Configuration Issues

### **Email Not Working**
1. Check SMTP settings
2. Verify firewall allows SMTP port
3. Test with telnet: `telnet smtp.gmail.com 587`
4. Check Jenkins logs for errors

### **Builds Not Starting**
1. Check executor availability
2. Verify agent connectivity
3. Check build queue
4. Review system logs

### **Performance Issues**
1. Increase JVM heap size: `-Xmx4g`
2. Reduce number of executors on master
3. Use agents for builds
4. Clean up old builds regularly

## 📋 Configuration Checklist

### **Initial Setup**
- [ ] Set Jenkins URL
- [ ] Configure admin email
- [ ] Enable security
- [ ] Set up SMTP
- [ ] Configure global tools
- [ ] Set build retention policy

### **Security Hardening**
- [ ] Enable CSRF protection
- [ ] Disable unnecessary protocols
- [ ] Configure proper authorization
- [ ] Set up audit logging
- [ ] Regular security updates

### **Performance Optimization**
- [ ] Appropriate executor count
- [ ] JVM tuning
- [ ] Build cleanup policies
- [ ] Agent distribution
- [ ] Plugin optimization