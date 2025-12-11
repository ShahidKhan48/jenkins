# Git Authentication Issues

## 🔑 Git Authentication Overview

Git authentication problems are among the most common SCM issues in Jenkins, affecting repository access and build triggers.

## 🚨 Common Authentication Errors

### **SSH Key Authentication Failures**
```
Permission denied (publickey)
Host key verification failed
git@github.com: Permission denied (publickey)
fatal: Could not read from remote repository
```

### **HTTPS Authentication Failures**
```
fatal: Authentication failed for 'https://github.com/user/repo.git'
remote: Invalid username or password
fatal: unable to access 'https://github.com/user/repo.git/': The requested URL returned error: 403
```

## 🔐 SSH Authentication Issues

### **SSH Key Setup**
```bash
# Generate SSH key for Jenkins
sudo -u jenkins ssh-keygen -t rsa -b 4096 -C "jenkins@company.com" -f /var/lib/jenkins/.ssh/id_rsa

# Set correct permissions
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa*
sudo chmod 600 /var/lib/jenkins/.ssh/id_rsa
sudo chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub

# Add to SSH agent
sudo -u jenkins ssh-add /var/lib/jenkins/.ssh/id_rsa
```

### **Test SSH Connection**
```bash
# Test GitHub connection
sudo -u jenkins ssh -T git@github.com

# Test GitLab connection
sudo -u jenkins ssh -T git@gitlab.com

# Test with verbose output
sudo -u jenkins ssh -vvv -T git@github.com
```

### **SSH Configuration**
```bash
# Create SSH config for Jenkins
sudo -u jenkins tee /var/lib/jenkins/.ssh/config << EOF
Host github.com
    HostName github.com
    User git
    IdentityFile /var/lib/jenkins/.ssh/id_rsa
    StrictHostKeyChecking no

Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile /var/lib/jenkins/.ssh/id_rsa
    StrictHostKeyChecking no
EOF

sudo chmod 600 /var/lib/jenkins/.ssh/config
```

### **Known Hosts Management**
```bash
# Add known hosts
sudo -u jenkins ssh-keyscan github.com >> /var/lib/jenkins/.ssh/known_hosts
sudo -u jenkins ssh-keyscan gitlab.com >> /var/lib/jenkins/.ssh/known_hosts

# Or disable host key checking (less secure)
echo "StrictHostKeyChecking no" >> /var/lib/jenkins/.ssh/config
```

## 🌐 HTTPS Authentication Issues

### **Personal Access Tokens**
```groovy
// Create credential for GitHub token
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*

def store = SystemCredentialsProvider.getInstance().getStore()
def domain = Domain.global()

def credential = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    "github-token",
    "GitHub Personal Access Token",
    "username",
    "ghp_xxxxxxxxxxxxxxxxxxxx"
)

store.addCredentials(domain, credential)
```

### **Git Credential Helper**
```bash
# Configure git credential helper
sudo -u jenkins git config --global credential.helper store

# Store credentials
echo "https://username:token@github.com" > /var/lib/jenkins/.git-credentials
sudo chown jenkins:jenkins /var/lib/jenkins/.git-credentials
sudo chmod 600 /var/lib/jenkins/.git-credentials
```

### **URL Rewriting for HTTPS**
```bash
# Rewrite SSH URLs to HTTPS
sudo -u jenkins git config --global url."https://github.com/".insteadOf "git@github.com:"
sudo -u jenkins git config --global url."https://gitlab.com/".insteadOf "git@gitlab.com:"
```

## 🏢 Enterprise Git Solutions

### **GitLab Enterprise**
```groovy
// GitLab API token credential
def gitlabToken = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    "gitlab-api-token",
    "GitLab API Token",
    Secret.fromString("glpat-xxxxxxxxxxxxxxxxxxxx")
)

store.addCredentials(domain, gitlabToken)
```

### **Bitbucket Server**
```bash
# Bitbucket SSH key setup
sudo -u jenkins ssh-keygen -t rsa -b 4096 -f /var/lib/jenkins/.ssh/bitbucket_rsa

# Add to SSH config
cat >> /var/lib/jenkins/.ssh/config << EOF
Host bitbucket.company.com
    HostName bitbucket.company.com
    User git
    IdentityFile /var/lib/jenkins/.ssh/bitbucket_rsa
    Port 7999
EOF
```

### **Azure DevOps**
```groovy
// Azure DevOps PAT credential
def azureToken = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    "azure-devops-pat",
    "Azure DevOps PAT",
    "username",
    "pat-token-here"
)
```

## 🔧 Credential Management

### **Jenkins Credentials Store**
```groovy
// List all credentials
import com.cloudbees.plugins.credentials.*

def creds = CredentialsProvider.lookupCredentials(
    StandardCredentials.class,
    Jenkins.instance,
    null,
    null
)

creds.each { cred ->
    println "ID: ${cred.id}"
    println "Description: ${cred.description}"
    println "Type: ${cred.class.simpleName}"
    println "---"
}
```

### **SSH Key Credential**
```groovy
// Add SSH private key credential
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*

def privateKey = new File("/var/lib/jenkins/.ssh/id_rsa").text
def sshKey = new BasicSSHUserPrivateKey(
    CredentialsScope.GLOBAL,
    "jenkins-ssh-key",
    "jenkins",
    new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(privateKey),
    "",
    "Jenkins SSH Key"
)

store.addCredentials(domain, sshKey)
```

## 🔍 Debugging Authentication

### **Git Debug Commands**
```bash
# Enable Git debugging
export GIT_TRACE=1
export GIT_CURL_VERBOSE=1
export GIT_SSH_COMMAND="ssh -vvv"

# Test git operations
sudo -u jenkins git ls-remote https://github.com/user/repo.git
sudo -u jenkins git clone git@github.com:user/repo.git /tmp/test-clone
```

### **Jenkins Git Plugin Debug**
```groovy
// Enable Git plugin debugging
import java.util.logging.*

def logger = Logger.getLogger("hudson.plugins.git")
logger.setLevel(Level.FINE)

def handler = new ConsoleHandler()
handler.setLevel(Level.FINE)
logger.addHandler(handler)
```

### **SSH Agent Debugging**
```bash
# Check SSH agent
sudo -u jenkins ssh-add -l

# Start SSH agent if needed
eval $(sudo -u jenkins ssh-agent)
sudo -u jenkins ssh-add /var/lib/jenkins/.ssh/id_rsa

# Test with agent
sudo -u jenkins SSH_AUTH_SOCK=$SSH_AUTH_SOCK ssh -T git@github.com
```

## 🛠️ Common Fixes

### **Reset Git Configuration**
```bash
# Clear git configuration
sudo -u jenkins git config --global --unset-all credential.helper
sudo -u jenkins git config --global --unset-all url.https://github.com/.insteadof

# Remove stored credentials
sudo rm -f /var/lib/jenkins/.git-credentials
sudo rm -f /var/lib/jenkins/.gitconfig
```

### **Regenerate SSH Keys**
```bash
#!/bin/bash
# regenerate-ssh-keys.sh

JENKINS_HOME="/var/lib/jenkins"
SSH_DIR="${JENKINS_HOME}/.ssh"

# Backup existing keys
sudo -u jenkins cp -r "${SSH_DIR}" "${SSH_DIR}.backup.$(date +%Y%m%d)"

# Generate new keys
sudo -u jenkins ssh-keygen -t rsa -b 4096 -f "${SSH_DIR}/id_rsa" -N ""

# Set permissions
sudo chmod 600 "${SSH_DIR}/id_rsa"
sudo chmod 644 "${SSH_DIR}/id_rsa.pub"

echo "New SSH key generated:"
sudo cat "${SSH_DIR}/id_rsa.pub"
```

### **Credential Rotation Script**
```groovy
// Rotate Git credentials
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.impl.*

def updateCredential = { credId, newPassword ->
    def cred = CredentialsProvider.lookupCredentials(
        UsernamePasswordCredentials.class,
        Jenkins.instance,
        null,
        null
    ).find { it.id == credId }
    
    if (cred) {
        def newCred = new UsernamePasswordCredentialsImpl(
            cred.scope,
            cred.id,
            cred.description,
            cred.username,
            newPassword
        )
        
        def store = SystemCredentialsProvider.getInstance().getStore()
        store.updateCredentials(Domain.global(), cred, newCred)
        
        println "Updated credential: ${credId}"
    }
}

// Usage
updateCredential("github-token", "new-token-value")
```

## 🔐 Security Best Practices

### **Token Management**
```bash
# GitHub token with minimal permissions
# Required scopes: repo, read:org

# GitLab token with minimal access
# Required scopes: read_repository, read_user

# Rotate tokens regularly (90 days)
```

### **SSH Key Security**
```bash
# Use Ed25519 keys (more secure)
sudo -u jenkins ssh-keygen -t ed25519 -C "jenkins@company.com"

# Use passphrase-protected keys
sudo -u jenkins ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_protected

# Configure SSH agent forwarding carefully
```

### **Network Security**
```bash
# Restrict Git access by IP
# In firewall rules or Git provider settings

# Use VPN for private repositories
# Configure Jenkins to use VPN connection

# Monitor Git access logs
tail -f /var/log/auth.log | grep ssh
```

## 📊 Monitoring Git Authentication

### **Authentication Metrics**
```groovy
// Monitor Git authentication failures
def gitFailures = Jenkins.instance.getAllItems(Job.class).findAll { job ->
    job.getLastBuild()?.getLog(50)?.any { line ->
        line.contains("Authentication failed") || 
        line.contains("Permission denied")
    }
}

gitFailures.each { job ->
    println "Git auth failure in job: ${job.fullName}"
}
```

### **Credential Usage Tracking**
```groovy
// Track credential usage
import com.cloudbees.plugins.credentials.CredentialsProvider

def trackCredentialUsage = { ->
    def usage = [:]
    
    Jenkins.instance.getAllItems(Job.class).each { job ->
        job.getProperty(ParametersDefinitionProperty.class)?.parameterDefinitions?.each { param ->
            if (param instanceof CredentialsParameterDefinition) {
                usage[param.defaultValue] = (usage[param.defaultValue] ?: 0) + 1
            }
        }
    }
    
    return usage
}

def usage = trackCredentialUsage()
usage.each { credId, count ->
    println "Credential ${credId} used in ${count} jobs"
}
```

## 📋 Troubleshooting Checklist

### **SSH Authentication**
- [ ] SSH key exists and has correct permissions
- [ ] Public key added to Git provider
- [ ] SSH agent running and key loaded
- [ ] Known hosts configured
- [ ] SSH config file correct

### **HTTPS Authentication**
- [ ] Valid personal access token
- [ ] Token has required permissions
- [ ] Credential stored in Jenkins
- [ ] URL format correct
- [ ] No expired tokens

### **Network Issues**
- [ ] Git provider accessible
- [ ] Firewall allows Git traffic
- [ ] Proxy configuration correct
- [ ] DNS resolution working
- [ ] SSL certificates valid