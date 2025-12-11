# User Management and Security

## Overview
User management and security are critical aspects of Jenkins administration. This guide covers authentication methods, authorization strategies, user account management, and security best practices.

## Authentication Methods

### 1. Jenkins Database (Local Users)
```
┌─────────────────────────────────────────────────────────────┐
│                🔐 Local User Authentication                 │
├─────────────────────────────────────────────────────────────┤
│ Configuration Path:                                         │
│ Manage Jenkins → Configure Global Security → Security Realm │
│                                                             │
│ Settings:                                                   │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🔘 Jenkins' own user database                           │ │
│ │ ☑️ Allow users to sign up                               │ │
│ │ ☐ Allow users to sign up (for production)               │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ User Creation Process:                                      │
│ 1. Admin creates user accounts                              │
│ 2. Users receive initial credentials                        │
│ 3. Users change password on first login                     │
│ 4. Password policies enforced                               │
│                                                             │
│ Best For:                                                   │
│ • Small teams (< 20 users)                                 │
│ • Development environments                                  │
│ • Quick setup and testing                                   │
│ • No external authentication system                         │
└─────────────────────────────────────────────────────────────┘
```

### 2. LDAP Authentication
```
┌─────────────────────────────────────────────────────────────┐
│                   🏢 LDAP Authentication                    │
├─────────────────────────────────────────────────────────────┤
│ Configuration:                                              │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🔘 LDAP                                                 │ │
│ │                                                         │ │
│ │ Server: [ldap://ldap.company.com:389        ]           │ │
│ │ Root DN: [dc=company,dc=com                 ]           │ │
│ │ User search base: [ou=users                 ]           │ │
│ │ User search filter: [uid={0}                ]           │ │
│ │ Group search base: [ou=groups               ]           │ │
│ │ Group search filter: [cn={0}                ]           │ │
│ │ Group membership: [memberUid={1}            ]           │ │
│ │                                                         │ │
│ │ Manager DN: [cn=jenkins,ou=service,dc=company,dc=com]   │ │
│ │ Manager Password: [********************    ]           │ │
│ │                                                         │ │
│ │ ☑️ Inhibit Infer Root DN                                │ │
│ │ ☑️ Enable cache                                         │ │
│ │ Cache Size: [20                             ]           │ │
│ │ Cache TTL: [300                             ]           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Advanced Settings:                                          │
│ • SSL/TLS encryption                                        │
│ • Connection timeout                                        │
│ • Read timeout                                              │
│ • Connection pooling                                        │
└─────────────────────────────────────────────────────────────┘
```

### 3. Active Directory Authentication
```
┌─────────────────────────────────────────────────────────────┐
│               🏢 Active Directory Authentication            │
├─────────────────────────────────────────────────────────────┤
│ Configuration:                                              │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🔘 Active Directory                                     │ │
│ │                                                         │ │
│ │ Domain Name: [company.com                   ]           │ │
│ │ Domain Controller: [dc1.company.com:3268    ]           │ │
│ │ Site: [Default-First-Site-Name              ]           │ │
│ │ Bind DN: [jenkins@company.com               ]           │ │
│ │ Bind Password: [********************       ]           │ │
│ │                                                         │ │
│ │ Advanced Settings:                                      │ │
│ │ ☑️ Enable StartTLS                                      │ │
│ │ ☑️ Allow blank nested DN                                │ │
│ │ Group Lookup Strategy: [RECURSIVE           ▼]         │ │
│ │ Remove Irrelevant Groups: ☑️                           │ │
│ │                                                         │ │
│ │ Cache Configuration:                                    │ │
│ │ Cache Size: [100                            ]           │ │
│ │ Cache TTL: [3600                            ]           │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 4. SAML SSO Authentication
```yaml
# SAML Configuration Example
saml:
  displayNameAttributeName: "displayName"
  emailAttributeName: "email"
  groupsAttributeName: "groups"
  idpMetadataConfiguration:
    period: 15
    url: "https://company.okta.com/app/jenkins/metadata"
  maximumAuthenticationLifetime: 86400
  usernameAttributeName: "username"
  usernameCaseConversion: "none"
```

## Authorization Strategies

### 1. Matrix-based Security
```
┌─────────────────────────────────────────────────────────────┐
│                🔒 Matrix-based Security                     │
├─────────────────────────────────────────────────────────────┤
│ Configuration Path:                                         │
│ Manage Jenkins → Configure Global Security → Authorization  │
│                                                             │
│ Permission Matrix:                                          │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ User/Group    │Overall│Agent│Job │Run │View│SCM│Create│ │ │
│ ├───────────────┼───────┼─────┼────┼────┼────┼───┼──────┤ │ │
│ │ admin         │ ✅✅✅ │ ✅✅ │✅✅✅│✅✅ │✅✅ │✅✅│ ✅✅  │ │ │
│ │ developers    │ ✅⚪⚪ │ ✅⚪ │✅✅⚪│✅✅ │✅✅ │✅⚪│ ✅⚪  │ │ │
│ │ testers       │ ✅⚪⚪ │ ⚪⚪ │⚪✅⚪│✅✅ │✅✅ │⚪⚪│ ⚪⚪  │ │ │
│ │ viewers       │ ✅⚪⚪ │ ⚪⚪ │⚪⚪⚪│⚪⚪ │✅✅ │⚪⚪│ ⚪⚪  │ │ │
│ │ anonymous     │ ⚪⚪⚪ │ ⚪⚪ │⚪⚪⚪│⚪⚪ │✅⚪ │⚪⚪│ ⚪⚪  │ │ │
│ └───────────────┴───────┴─────┴────┴────┴────┴───┴──────┘ │ │
│                                                             │
│ Permission Categories:                                      │
│ • Overall: Administer, Read, RunScripts                    │
│ • Agent: Build, Configure, Connect, Create, Delete         │
│ • Job: Build, Cancel, Configure, Create, Delete, Read      │
│ • Run: Delete, Replay, Update                               │
│ • View: Configure, Create, Delete, Read                     │
│ • SCM: Tag                                                  │
└─────────────────────────────────────────────────────────────┘
```

### 2. Project-based Matrix Authorization
```
┌─────────────────────────────────────────────────────────────┐
│            🎯 Project-based Matrix Authorization            │
├─────────────────────────────────────────────────────────────┤
│ Folder-Level Permissions:                                   │
│                                                             │
│ Frontend Team Folder:                                       │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ User/Group        │ Discover │ Read │ Build │ Configure │ │ │
│ ├───────────────────┼──────────┼──────┼───────┼───────────┤ │ │
│ │ frontend-devs     │    ✅    │  ✅  │  ✅   │    ✅     │ │ │
│ │ frontend-leads    │    ✅    │  ✅  │  ✅   │    ✅     │ │ │
│ │ qa-team          │    ✅    │  ✅  │  ✅   │    ⚪     │ │ │
│ │ other-teams      │    ✅    │  ✅  │  ⚪   │    ⚪     │ │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Job-Level Permissions:                                      │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Production Deploy Job:                                  │ │
│ │ • deploy-leads: Full access                             │ │
│ │ • senior-devs: Build and read access                    │ │
│ │ • junior-devs: Read access only                         │ │
│ │ • qa-team: Read access only                             │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 3. Role-based Authorization Strategy
```
┌─────────────────────────────────────────────────────────────┐
│              👥 Role-based Authorization                    │
├─────────────────────────────────────────────────────────────┤
│ Role Definitions:                                           │
│                                                             │
│ 🔴 Administrator Role:                                      │
│ • Full system access                                        │
│ • User management                                           │
│ • System configuration                                      │
│ • Plugin management                                         │
│ • Security settings                                         │
│                                                             │
│ 🟡 Developer Role:                                          │
│ • Create and configure jobs                                 │
│ • Build and deploy to dev/staging                           │
│ • View build results and logs                               │
│ • Manage own credentials                                    │
│                                                             │
│ 🟢 Tester Role:                                             │
│ • Execute test jobs                                         │
│ • View test results                                         │
│ • Access test environments                                  │
│ • Read-only access to configurations                        │
│                                                             │
│ 🔵 Viewer Role:                                             │
│ • Read-only access to jobs                                  │
│ • View build history                                        │
│ • Access to reports and dashboards                          │
│ • No modification permissions                               │
│                                                             │
│ Role Assignment:                                            │
│ • Users can have multiple roles                             │
│ • Roles can be inherited from groups                        │
│ • Project-specific role assignments                         │
└─────────────────────────────────────────────────────────────┘
```

## User Account Management

### Creating User Accounts
```bash
#!/bin/bash
# create-jenkins-users.sh

JENKINS_URL="http://localhost:8080"
ADMIN_USER="admin"
ADMIN_TOKEN="your-admin-token"

# Function to create user
create_user() {
    local username=$1
    local password=$2
    local fullname=$3
    local email=$4
    
    echo "Creating user: $username"
    
    # Create user via Jenkins CLI
    java -jar jenkins-cli.jar -s $JENKINS_URL \
        -auth $ADMIN_USER:$ADMIN_TOKEN \
        groovy = <<EOF
import jenkins.model.*
import hudson.security.*
import hudson.tasks.Mailer

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def users = hudsonRealm.getAllUsers()

// Check if user already exists
if (!users.find { it.getId() == '$username' }) {
    hudsonRealm.createAccount('$username', '$password')
    def user = hudson.model.User.get('$username')
    user.setFullName('$fullname')
    user.addProperty(new Mailer.UserProperty('$email'))
    user.save()
    println "User $username created successfully"
} else {
    println "User $username already exists"
}

instance.setSecurityRealm(hudsonRealm)
instance.save()
EOF
}

# Create multiple users
create_user "john.doe" "TempPass123!" "John Doe" "john.doe@company.com"
create_user "jane.smith" "TempPass123!" "Jane Smith" "jane.smith@company.com"
create_user "bob.wilson" "TempPass123!" "Bob Wilson" "bob.wilson@company.com"

echo "User creation completed"
```

### User Management Operations
```bash
#!/bin/bash
# user-management-operations.sh

JENKINS_URL="http://localhost:8080"
ADMIN_USER="admin"
ADMIN_TOKEN="your-admin-token"

# List all users
list_users() {
    echo "=== ALL JENKINS USERS ==="
    java -jar jenkins-cli.jar -s $JENKINS_URL \
        -auth $ADMIN_USER:$ADMIN_TOKEN \
        groovy = <<'EOF'
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def securityRealm = instance.getSecurityRealm()

if (securityRealm instanceof HudsonPrivateSecurityRealm) {
    securityRealm.getAllUsers().each { user ->
        def userObj = hudson.model.User.get(user.getId(), false)
        if (userObj) {
            def email = userObj.getProperty(hudson.tasks.Mailer.UserProperty.class)?.getAddress() ?: "No email"
            println "${user.getId()} | ${userObj.getFullName()} | ${email}"
        }
    }
} else {
    println "Not using Jenkins database for users"
}
EOF
}

# Disable user account
disable_user() {
    local username=$1
    echo "Disabling user: $username"
    
    java -jar jenkins-cli.jar -s $JENKINS_URL \
        -auth $ADMIN_USER:$ADMIN_TOKEN \
        groovy = <<EOF
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def securityRealm = instance.getSecurityRealm()

if (securityRealm instanceof HudsonPrivateSecurityRealm) {
    def user = hudson.model.User.get('$username', false)
    if (user) {
        // Add user to disabled group or remove permissions
        println "User $username disabled"
    } else {
        println "User $username not found"
    }
}
EOF
}

# Reset user password
reset_password() {
    local username=$1
    local new_password=$2
    
    echo "Resetting password for user: $username"
    
    java -jar jenkins-cli.jar -s $JENKINS_URL \
        -auth $ADMIN_USER:$ADMIN_TOKEN \
        groovy = <<EOF
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def securityRealm = instance.getSecurityRealm()

if (securityRealm instanceof HudsonPrivateSecurityRealm) {
    def userDetails = securityRealm.loadUserByUsername('$username')
    securityRealm.getSecurityComponents().userDetails.updatePassword(userDetails, '$new_password')
    println "Password reset for user $username"
}
EOF
}

# Execute operations
case "$1" in
    "list")
        list_users
        ;;
    "disable")
        disable_user "$2"
        ;;
    "reset-password")
        reset_password "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {list|disable <username>|reset-password <username> <new_password>}"
        ;;
esac
```

## Security Configuration

### Password Policy Configuration
```
┌─────────────────────────────────────────────────────────────┐
│                🔐 Password Policy Configuration             │
├─────────────────────────────────────────────────────────────┤
│ Manage Jenkins → Configure Global Security → Password Policy│
│                                                             │
│ Policy Settings:                                            │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Minimum Length: [12                         ]           │ │
│ │ Maximum Length: [128                        ]           │ │
│ │                                                         │ │
│ │ Character Requirements:                                 │ │
│ │ ☑️ At least 1 uppercase letter                         │ │
│ │ ☑️ At least 1 lowercase letter                         │ │
│ │ ☑️ At least 1 digit                                    │ │
│ │ ☑️ At least 1 special character                        │ │
│ │                                                         │ │
│ │ Restrictions:                                           │ │
│ │ ☑️ Cannot contain username                              │ │
│ │ ☑️ Cannot be common passwords                           │ │
│ │ ☑️ Cannot reuse last 5 passwords                       │ │
│ │                                                         │ │
│ │ Expiration:                                             │ │
│ │ Password expires after: [90] days                       │ │
│ │ Warning before expiration: [7] days                     │ │
│ │ Grace period after expiration: [3] days                 │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### API Token Management
```bash
#!/bin/bash
# api-token-management.sh

JENKINS_URL="http://localhost:8080"
USERNAME="admin"
PASSWORD="admin-password"

# Generate API token for user
generate_token() {
    local user=$1
    local token_name=$2
    
    echo "Generating API token for user: $user"
    
    # Get crumb for CSRF protection
    CRUMB=$(curl -s -u "$USERNAME:$PASSWORD" \
        "$JENKINS_URL/crumbIssuer/api/json" | \
        jq -r '.crumb')
    
    # Generate token
    TOKEN_RESPONSE=$(curl -s -X POST \
        -u "$USERNAME:$PASSWORD" \
        -H "Jenkins-Crumb: $CRUMB" \
        "$JENKINS_URL/user/$user/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" \
        --data "newTokenName=$token_name")
    
    TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.tokenValue')
    echo "Generated token: $TOKEN"
    echo "Store this token securely - it cannot be retrieved again"
}

# List API tokens for user
list_tokens() {
    local user=$1
    
    echo "API tokens for user: $user"
    
    curl -s -u "$USERNAME:$PASSWORD" \
        "$JENKINS_URL/user/$user/api/json" | \
        jq -r '.property[] | select(.tokenStats) | .tokenStats[] | "\(.name) - Created: \(.creationDate)"'
}

# Revoke API token
revoke_token() {
    local user=$1
    local token_uuid=$2
    
    echo "Revoking token for user: $user"
    
    CRUMB=$(curl -s -u "$USERNAME:$PASSWORD" \
        "$JENKINS_URL/crumbIssuer/api/json" | \
        jq -r '.crumb')
    
    curl -s -X POST \
        -u "$USERNAME:$PASSWORD" \
        -H "Jenkins-Crumb: $CRUMB" \
        "$JENKINS_URL/user/$user/descriptorByName/jenkins.security.ApiTokenProperty/revoke" \
        --data "tokenUuid=$token_uuid"
    
    echo "Token revoked successfully"
}

# Execute operations
case "$1" in
    "generate")
        generate_token "$2" "$3"
        ;;
    "list")
        list_tokens "$2"
        ;;
    "revoke")
        revoke_token "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {generate <user> <token_name>|list <user>|revoke <user> <token_uuid>}"
        ;;
esac
```

## Security Hardening

### Security Checklist
```
┌─────────────────────────────────────────────────────────────┐
│                🛡️ Security Hardening Checklist             │
├─────────────────────────────────────────────────────────────┤
│ Authentication & Authorization:                             │
│ ☑️ Strong authentication method configured                  │
│ ☑️ Matrix-based or role-based authorization enabled         │
│ ☑️ Anonymous access disabled                                │
│ ☑️ User signup disabled (production)                        │
│ ☑️ Strong password policy enforced                          │
│                                                             │
│ Network Security:                                           │
│ ☑️ HTTPS/SSL enabled with valid certificates               │
│ ☑️ Firewall rules configured                                │
│ ☑️ VPN access for remote users                              │
│ ☑️ Network segmentation implemented                         │
│                                                             │
│ System Security:                                            │
│ ☑️ Jenkins running as non-root user                         │
│ ☑️ File system permissions properly configured              │
│ ☑️ Regular security updates applied                         │
│ ☑️ Unnecessary services disabled                            │
│                                                             │
│ Audit & Monitoring:                                         │
│ ☑️ Audit logging enabled                                    │
│ ☑️ Security monitoring configured                           │
│ ☑️ Failed login attempt monitoring                          │
│ ☑️ Regular security assessments                             │
│                                                             │
│ Backup & Recovery:                                          │
│ ☑️ Regular backups configured                               │
│ ☑️ Backup encryption enabled                                │
│ ☑️ Disaster recovery plan documented                        │
│ ☑️ Recovery procedures tested                               │
└─────────────────────────────────────────────────────────────┘
```

### Security Monitoring Script
```bash
#!/bin/bash
# security-monitoring.sh

JENKINS_URL="http://localhost:8080"
LOG_FILE="/var/log/jenkins/security-monitor.log"

# Function to log security events
log_security_event() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Monitor failed login attempts
monitor_failed_logins() {
    echo "Monitoring failed login attempts..."
    
    # Check Jenkins logs for failed logins
    FAILED_LOGINS=$(grep -c "Failed to authenticate" /var/log/jenkins/jenkins.log)
    
    if [ "$FAILED_LOGINS" -gt 10 ]; then
        log_security_event "HIGH: $FAILED_LOGINS failed login attempts detected"
        # Send alert
        echo "Security Alert: High number of failed login attempts" | \
            mail -s "Jenkins Security Alert" admin@company.com
    fi
}

# Check for suspicious user activities
monitor_user_activities() {
    echo "Monitoring user activities..."
    
    # Check for users created outside business hours
    RECENT_USERS=$(grep "User.*created" /var/log/jenkins/jenkins.log | \
        grep "$(date +%Y-%m-%d)" | wc -l)
    
    if [ "$RECENT_USERS" -gt 0 ]; then
        log_security_event "INFO: $RECENT_USERS new users created today"
    fi
}

# Check system integrity
check_system_integrity() {
    echo "Checking system integrity..."
    
    # Check for unauthorized file modifications
    find $JENKINS_HOME -name "*.xml" -mtime -1 -exec ls -la {} \; | \
        grep -v "$(date +%Y-%m-%d)" > /tmp/modified_configs.txt
    
    if [ -s /tmp/modified_configs.txt ]; then
        log_security_event "WARNING: Configuration files modified outside normal hours"
    fi
}

# Check plugin security
check_plugin_security() {
    echo "Checking plugin security..."
    
    # Check for plugins with known vulnerabilities
    curl -s "https://updates.jenkins.io/update-center.json" | \
        jq -r '.warnings[] | select(.type == "plugin") | .name' > /tmp/vulnerable_plugins.txt
    
    # Compare with installed plugins
    java -jar jenkins-cli.jar -s $JENKINS_URL list-plugins | \
        awk '{print $1}' > /tmp/installed_plugins.txt
    
    VULNERABLE_INSTALLED=$(comm -12 /tmp/vulnerable_plugins.txt /tmp/installed_plugins.txt)
    
    if [ -n "$VULNERABLE_INSTALLED" ]; then
        log_security_event "CRITICAL: Vulnerable plugins installed: $VULNERABLE_INSTALLED"
    fi
}

# Main monitoring loop
main() {
    log_security_event "Starting security monitoring"
    
    monitor_failed_logins
    monitor_user_activities
    check_system_integrity
    check_plugin_security
    
    log_security_event "Security monitoring completed"
}

# Run monitoring
main
```

## Lab Exercises

### Exercise 1: User Management Setup
1. Configure Jenkins database authentication
2. Create user accounts with different roles
3. Test login and permissions
4. Implement password policy

### Exercise 2: LDAP Integration
1. Set up LDAP authentication
2. Configure group mappings
3. Test user authentication
4. Troubleshoot connection issues

### Exercise 3: Matrix-based Security
1. Configure matrix-based authorization
2. Set up project-level permissions
3. Test different user access levels
4. Document permission matrix

### Exercise 4: Security Hardening
1. Implement security checklist items
2. Configure audit logging
3. Set up security monitoring
4. Test security measures

## Best Practices

### Authentication
- Use enterprise authentication systems (LDAP/AD)
- Implement multi-factor authentication where possible
- Regular password policy reviews
- Monitor authentication failures

### Authorization
- Apply principle of least privilege
- Use project-based permissions
- Regular permission audits
- Document access control policies

### Security
- Enable HTTPS/SSL
- Regular security updates
- Implement audit logging
- Security monitoring and alerting

### User Management
- Standardized user provisioning process
- Regular user access reviews
- Automated user lifecycle management
- Clear documentation of roles and responsibilities

## Next Steps

After mastering user management and security:
1. Learn advanced security configurations
2. Implement compliance frameworks
3. Set up automated security monitoring
4. Explore enterprise authentication integrations