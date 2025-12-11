# User Management

## 👥 User Management Overview

Jenkins user management involves creating, configuring, and managing user accounts, permissions, and authentication methods.

## 🔐 Security Realms

### **Jenkins' Own User Database**
```
Manage Jenkins → Configure Global Security
Security Realm: Jenkins' own user database
☑ Allow users to sign up
```

### **LDAP Integration**
```
Security Realm: LDAP
Server: ldap://ldap.company.com:389
Root DN: dc=company,dc=com
User search base: ou=users
User search filter: uid={0}
Group search base: ou=groups
Group search filter: (& (cn={0}) (objectclass=groupOfUniqueNames))
Group membership: Search for LDAP groups containing user
Manager DN: cn=admin,dc=company,dc=com
Manager Password: [password]
```

### **Active Directory**
```
Security Realm: Active Directory
Domain: company.com
Domain Controller: dc.company.com:3268
Bind DN: jenkins@company.com
Bind Password: [password]
```

## 👤 Creating Users

### **Manual User Creation**
1. Navigate to **Manage Jenkins → Manage Users**
2. Click **Create User**
3. Fill in user details:
   ```
   Username: john.doe
   Password: [secure-password]
   Confirm password: [secure-password]
   Full name: John Doe
   E-mail address: john.doe@company.com
   ```

### **Programmatic User Creation**
```groovy
// Groovy script for user creation
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)

// Create users
hudsonRealm.createAccount("developer1", "password123")
hudsonRealm.createAccount("developer2", "password456")
hudsonRealm.createAccount("admin", "admin-password")

instance.setSecurityRealm(hudsonRealm)
instance.save()
```

### **Bulk User Import**
```groovy
// Bulk user creation from CSV
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)

// User data (username, password, fullName, email)
def users = [
    ["alice", "pass123", "Alice Smith", "alice@company.com"],
    ["bob", "pass456", "Bob Johnson", "bob@company.com"],
    ["charlie", "pass789", "Charlie Brown", "charlie@company.com"]
]

users.each { userData ->
    def user = hudsonRealm.createAccount(userData[0], userData[1])
    user.setFullName(userData[2])
    user.addProperty(new hudson.tasks.Mailer.UserProperty(userData[3]))
}

instance.setSecurityRealm(hudsonRealm)
instance.save()
```

## 🔑 Authorization Strategies

### **Matrix-based Security**
```
Authorization: Matrix-based security

Global permissions:
├── Overall
│   ├── Administer: admin
│   ├── Read: authenticated
│   └── SystemRead: authenticated
├── Job
│   ├── Build: developers
│   ├── Cancel: developers
│   ├── Create: developers
│   ├── Delete: admin
│   ├── Read: authenticated
│   └── Workspace: developers
└── View
    ├── Create: developers
    ├── Delete: admin
    └── Read: authenticated
```

### **Project-based Matrix Authorization**
```groovy
// Configure project-based security
import jenkins.model.*
import hudson.security.*
import org.jenkinsci.plugins.matrixauth.*

def instance = Jenkins.getInstance()

def strategy = new ProjectMatrixAuthorizationStrategy()

// Global permissions
strategy.add(Jenkins.ADMINISTER, "admin")
strategy.add(Jenkins.READ, "authenticated")

// Job permissions
strategy.add(Job.BUILD, "developers")
strategy.add(Job.READ, "authenticated")
strategy.add(Job.WORKSPACE, "developers")

instance.setAuthorizationStrategy(strategy)
instance.save()
```

### **Role-based Authorization**
```
Plugin: Role-based Authorization Strategy

Global roles:
├── admin
│   └── Permissions: Overall/Administer
├── developer
│   └── Permissions: Overall/Read, Job/Build, Job/Read
└── viewer
    └── Permissions: Overall/Read, Job/Read

Project roles:
├── project-admin
│   └── Pattern: project-.*
│   └── Permissions: Job/*, Build/*, Run/*
└── project-developer
    └── Pattern: project-.*
    └── Permissions: Job/Build, Job/Read, Job/Workspace
```

## 👥 User Groups

### **LDAP Groups**
```
Group search base: ou=groups,dc=company,dc=com
Group search filter: (& (cn={0}) (objectclass=groupOfUniqueNames))
Group membership attribute: uniqueMember

Groups:
├── jenkins-admins
├── jenkins-developers
├── jenkins-viewers
└── jenkins-build-agents
```

### **Active Directory Groups**
```groovy
// Map AD groups to Jenkins permissions
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def strategy = new GlobalMatrixAuthorizationStrategy()

// Map AD groups
strategy.add(Jenkins.ADMINISTER, "COMPANY\\Jenkins Admins")
strategy.add(Jenkins.READ, "COMPANY\\Jenkins Users")
strategy.add(Job.BUILD, "COMPANY\\Developers")
strategy.add(Job.READ, "COMPANY\\Jenkins Users")

instance.setAuthorizationStrategy(strategy)
instance.save()
```

## 🔐 User Permissions

### **Permission Types**

#### **Overall Permissions**
```
Overall/Administer - Full system administration
Overall/Read - View Jenkins main page
Overall/RunScripts - Execute Groovy scripts
Overall/UploadPlugins - Upload plugin files
Overall/ConfigureUpdateCenter - Configure update sites
Overall/SystemRead - View system information
```

#### **Job Permissions**
```
Job/Create - Create new jobs
Job/Delete - Delete jobs
Job/Configure - Modify job configuration
Job/Read - View job details
Job/Build - Start builds
Job/Cancel - Cancel running builds
Job/Workspace - Access job workspace
Job/Discover - Discover job existence
```

#### **Build Permissions**
```
Build/Delete - Delete build records
Build/Update - Update build information
```

#### **View Permissions**
```
View/Create - Create new views
View/Delete - Delete views
View/Configure - Modify view configuration
View/Read - View contents of views
```

### **Custom Permission Matrix**
```groovy
// Custom permission configuration
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def strategy = new GlobalMatrixAuthorizationStrategy()

// Admin users - full access
strategy.add(Jenkins.ADMINISTER, "admin")
strategy.add(Jenkins.ADMINISTER, "jenkins-admin")

// Developer group permissions
def devPermissions = [
    Jenkins.READ,
    Job.BUILD,
    Job.CANCEL,
    Job.READ,
    Job.WORKSPACE,
    Build.DELETE,
    View.READ
]

devPermissions.each { permission ->
    strategy.add(permission, "developers")
}

// Viewer permissions
strategy.add(Jenkins.READ, "viewers")
strategy.add(Job.READ, "viewers")
strategy.add(View.READ, "viewers")

instance.setAuthorizationStrategy(strategy)
instance.save()
```

## 🔧 User Configuration

### **User Profile Management**
```groovy
// Update user profiles
import jenkins.model.*
import hudson.model.*

def instance = Jenkins.getInstance()

// Get user
def user = User.get("john.doe")

// Update full name
user.setFullName("John Doe - Senior Developer")

// Update email
user.addProperty(new hudson.tasks.Mailer.UserProperty("john.doe@company.com"))

// Add description
user.setDescription("Senior Java Developer - Team Lead")

user.save()
```

### **API Token Management**
```groovy
// Generate API token for user
import jenkins.model.*
import hudson.model.*
import jenkins.security.*

def user = User.get("john.doe")
def apiTokenProperty = user.getProperty(ApiTokenProperty.class)

if (apiTokenProperty == null) {
    apiTokenProperty = new ApiTokenProperty()
    user.addProperty(apiTokenProperty)
}

// Generate new token
def token = apiTokenProperty.generateNewToken("automation-token")
println "Generated token for ${user.getId()}: ${token.plainValue}"

user.save()
```

## 🔍 User Monitoring

### **User Activity Tracking**
```groovy
// Track user login activity
import jenkins.model.*
import hudson.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

// Get all users
User.getAll().each { user ->
    def lastLogin = user.getProperty(hudson.security.SecurityRealm.UserProperty.class)
    println "User: ${user.getId()}"
    println "Full Name: ${user.getFullName()}"
    println "Email: ${user.getProperty(hudson.tasks.Mailer.UserProperty.class)?.getAddress()}"
    println "Last Login: ${lastLogin?.getLastGrantedAuthorities()}"
    println "---"
}
```

### **Permission Audit**
```groovy
// Audit user permissions
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def authStrategy = instance.getAuthorizationStrategy()

if (authStrategy instanceof GlobalMatrixAuthorizationStrategy) {
    def permissions = authStrategy.getAllPermissions()
    
    permissions.each { permission, users ->
        println "Permission: ${permission.name}"
        users.each { user ->
            println "  User/Group: ${user}"
        }
        println "---"
    }
}
```

## 🔒 Security Best Practices

### **Password Policies**
```groovy
// Enforce password complexity
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def realm = instance.getSecurityRealm()

if (realm instanceof HudsonPrivateSecurityRealm) {
    // Configure password requirements
    realm.setAllowsSignup(false)  // Disable self-registration
    
    // Custom password validation (requires plugin)
    // realm.setPasswordPolicy(new CustomPasswordPolicy())
}

instance.save()
```

### **Account Lockout**
```groovy
// Implement account lockout after failed attempts
import jenkins.security.*
import hudson.security.*

// Configure login attempt limits
def loginService = LoginService.getInstance()
loginService.setMaxLoginAttempts(5)
loginService.setLockoutDuration(300) // 5 minutes

// Monitor failed login attempts
def failedLogins = loginService.getFailedLoginAttempts()
failedLogins.each { username, attempts ->
    if (attempts >= 3) {
        println "Warning: User ${username} has ${attempts} failed login attempts"
    }
}
```

### **Session Management**
```groovy
// Configure session timeout
import jenkins.model.*

def instance = Jenkins.getInstance()

// Set session timeout (in seconds)
System.setProperty("hudson.security.SessionTimeout", "1800") // 30 minutes

// Force session invalidation
def descriptor = instance.getDescriptor("hudson.security.csrf.DefaultCrumbIssuer")
if (descriptor != null) {
    descriptor.setExcludeClientIPFromCrumb(false)
}

instance.save()
```

## 🔄 User Lifecycle Management

### **User Deactivation**
```groovy
// Deactivate user account
import jenkins.model.*
import hudson.model.*

def username = "former.employee"
def user = User.get(username, false)

if (user != null) {
    // Remove from all groups/permissions
    def authStrategy = Jenkins.getInstance().getAuthorizationStrategy()
    if (authStrategy instanceof GlobalMatrixAuthorizationStrategy) {
        authStrategy.getAllPermissions().each { permission, users ->
            users.remove(username)
        }
    }
    
    // Disable API tokens
    def apiTokenProperty = user.getProperty(ApiTokenProperty.class)
    if (apiTokenProperty != null) {
        apiTokenProperty.revokeAllTokens()
    }
    
    user.save()
    println "User ${username} deactivated"
}
```

### **User Cleanup**
```groovy
// Clean up inactive users
import jenkins.model.*
import hudson.model.*

def cutoffDate = new Date() - 90 // 90 days ago

User.getAll().each { user ->
    def builds = user.getBuilds()
    def lastActivity = builds.isEmpty() ? null : builds.first().getTime()
    
    if (lastActivity == null || lastActivity.before(cutoffDate)) {
        println "Inactive user: ${user.getId()} (last activity: ${lastActivity})"
        // Optionally delete: user.delete()
    }
}
```

## 💡 Best Practices

### **1. Principle of Least Privilege**
```
- Grant minimum permissions required
- Use groups instead of individual permissions
- Regular permission audits
- Remove unused accounts
```

### **2. Strong Authentication**
```
- Integrate with corporate directory (LDAP/AD)
- Enforce strong passwords
- Enable two-factor authentication
- Regular password rotation
```

### **3. User Lifecycle Management**
```
- Automated user provisioning
- Regular access reviews
- Prompt deactivation of former employees
- Audit trail of permission changes
```

### **4. Monitoring and Alerting**
```
- Monitor failed login attempts
- Alert on privilege escalation
- Track user activity
- Regular security assessments
```