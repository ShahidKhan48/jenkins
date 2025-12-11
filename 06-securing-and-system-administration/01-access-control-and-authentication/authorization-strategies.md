# Authorization Strategies

## 🔐 Authorization Overview

Jenkins authorization determines what authenticated users can do within the system.

## 🏠 Anyone Can Do Anything

### **Configuration**
```
Authorization Strategy: Anyone can do anything
```
- **Use Case**: Development environments only
- **Security Level**: None
- **Risk**: High - all users have full access

## 🔒 Legacy Mode

### **Configuration**
```
Authorization Strategy: Legacy mode
```
- Users with admin role have full access
- Other users have read access
- Simple but inflexible

## 📊 Matrix-Based Security

### **Project-Based Matrix**
```
Authorization Strategy: Project-based Matrix Authorization Strategy

Global Permissions:
- Overall/Administer: admin-group
- Overall/Read: authenticated-users
- Job/Create: developers
- Job/Build: developers, testers
- Job/Read: all-users
```

### **Matrix Configuration Script**
```groovy
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def strategy = new ProjectMatrixAuthorizationStrategy()

// Global permissions
strategy.add(Jenkins.ADMINISTER, "admin")
strategy.add(Jenkins.READ, "authenticated")
strategy.add(Item.CREATE, "developers")
strategy.add(Item.BUILD, "developers")
strategy.add(Item.READ, "all-users")

instance.setAuthorizationStrategy(strategy)
instance.save()
```

### **Per-Project Permissions**
```groovy
// Set project-specific permissions
import hudson.model.*
import hudson.security.*

def job = Jenkins.instance.getItem("my-project")
def authMatrix = new AuthorizationMatrixProperty()

authMatrix.add(Item.READ, "team-alpha")
authMatrix.add(Item.BUILD, "team-alpha")
authMatrix.add(Item.CONFIGURE, "team-lead")

job.addProperty(authMatrix)
job.save()
```

## 🔑 Role-Based Authorization

### **Role Strategy Plugin**
```groovy
import com.michelin.cio.hudson.plugins.rolestrategy.*
import jenkins.model.*

def roleStrategy = new RoleBasedAuthorizationStrategy()

// Global roles
def globalRoles = [
    "admin": [Jenkins.ADMINISTER],
    "developer": [Jenkins.READ, Item.CREATE, Item.BUILD],
    "viewer": [Jenkins.READ, Item.READ]
]

globalRoles.each { roleName, permissions ->
    def role = new Role(roleName, permissions as Set)
    roleStrategy.addRole(RoleBasedAuthorizationStrategy.GLOBAL, role)
}

Jenkins.instance.setAuthorizationStrategy(roleStrategy)
```

### **Project Roles**
```groovy
// Project-specific roles
def projectRoles = [
    "project-admin": [".*", [Item.CONFIGURE, Item.DELETE]],
    "project-developer": ["team-.*", [Item.BUILD, Item.READ]],
    "project-viewer": ["public-.*", [Item.READ]]
]

projectRoles.each { roleName, config ->
    def pattern = config[0]
    def permissions = config[1]
    def role = new Role(roleName, pattern, permissions as Set)
    roleStrategy.addRole(RoleBasedAuthorizationStrategy.PROJECT, role)
}
```

### **Node Roles**
```groovy
// Node-specific roles
def nodeRoles = [
    "node-admin": [".*", [Computer.CONFIGURE, Computer.DELETE]],
    "node-user": ["build-.*", [Computer.BUILD]]
]

nodeRoles.each { roleName, config ->
    def pattern = config[0]
    def permissions = config[1]
    def role = new Role(roleName, pattern, permissions as Set)
    roleStrategy.addRole(RoleBasedAuthorizationStrategy.SLAVE, role)
}
```

## 🏢 Folder-Based Authorization

### **Folder Plugin Setup**
```groovy
import com.cloudbees.hudson.plugins.folder.*
import com.cloudbees.hudson.plugins.folder.properties.*

def folder = Jenkins.instance.createProject(Folder.class, "team-alpha")
def authProperty = new AuthorizationMatrixProperty()

authProperty.add(Item.READ, "team-alpha-members")
authProperty.add(Item.BUILD, "team-alpha-members")
authProperty.add(Item.CONFIGURE, "team-alpha-leads")

folder.getProperties().add(authProperty)
folder.save()
```

### **Inheritance Configuration**
```groovy
// Configure permission inheritance
def folderAuth = new FolderBasedAuthorizationStrategy()
folderAuth.setInheritanceStrategy(
    FolderBasedAuthorizationStrategy.INHERITING
)
```

## 🔐 LDAP Group Authorization

### **LDAP Group Mapping**
```
LDAP Groups:
- CN=Jenkins-Admins,OU=Groups,DC=company,DC=com → admin
- CN=Developers,OU=Groups,DC=company,DC=com → developer
- CN=QA-Team,OU=Groups,DC=company,DC=com → tester
```

### **Group Authorization Script**
```groovy
import hudson.security.*
import jenkins.model.*

def strategy = new GlobalMatrixAuthorizationStrategy()

// Map LDAP groups to permissions
def groupPermissions = [
    "Jenkins-Admins": [Jenkins.ADMINISTER],
    "Developers": [Jenkins.READ, Item.CREATE, Item.BUILD, Item.CONFIGURE],
    "QA-Team": [Jenkins.READ, Item.BUILD, Item.READ],
    "Viewers": [Jenkins.READ, Item.READ]
]

groupPermissions.each { group, permissions ->
    permissions.each { permission ->
        strategy.add(permission, group)
    }
}

Jenkins.instance.setAuthorizationStrategy(strategy)
```

## 🎯 Custom Authorization Strategy

### **Custom Strategy Implementation**
```java
public class CustomAuthorizationStrategy extends AuthorizationStrategy {
    
    @Override
    public ACL getRootACL() {
        return new ACLImpl();
    }
    
    private class ACLImpl extends ACL {
        @Override
        public boolean hasPermission(Authentication auth, Permission permission) {
            // Custom authorization logic
            String username = auth.getName();
            
            if (isAdmin(username)) {
                return true;
            }
            
            if (permission == Jenkins.READ) {
                return isAuthenticated(auth);
            }
            
            return customPermissionCheck(username, permission);
        }
    }
}
```

### **Time-Based Authorization**
```groovy
// Time-based access control
import java.time.*

def isBusinessHours = {
    def now = LocalTime.now()
    def start = LocalTime.of(9, 0)
    def end = LocalTime.of(17, 0)
    return now.isAfter(start) && now.isBefore(end)
}

def customAuth = { username, permission ->
    if (permission == Item.BUILD && !isBusinessHours()) {
        return username in ["admin", "oncall-engineer"]
    }
    return true
}
```

## 📊 Permission Monitoring

### **Permission Audit Script**
```groovy
// Audit user permissions
import jenkins.model.*
import hudson.security.*

def strategy = Jenkins.instance.authorizationStrategy
def users = User.getAll()

users.each { user ->
    println "User: ${user.id}"
    
    Jenkins.PERMISSIONS.each { permission ->
        def hasPermission = strategy.rootACL.hasPermission(
            user.impersonate(), permission
        )
        if (hasPermission) {
            println "  - ${permission.id}"
        }
    }
    println ""
}
```

### **Permission Matrix Export**
```groovy
// Export permission matrix
def exportPermissions = { ->
    def matrix = [:]
    def users = User.getAll()
    
    users.each { user ->
        matrix[user.id] = [:]
        Jenkins.PERMISSIONS.each { permission ->
            matrix[user.id][permission.id] = strategy.rootACL.hasPermission(
                user.impersonate(), permission
            )
        }
    }
    
    return matrix
}

def permissions = exportPermissions()
println groovy.json.JsonBuilder(permissions).toPrettyString()
```

## 🔧 Authorization Configuration as Code

### **JCasC Authorization**
```yaml
jenkins:
  authorizationStrategy:
    projectMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"
        - "Job/Build:developers"
        - "Job/Configure:developers"
        - "Job/Create:developers"
        - "Job/Read:authenticated"
        - "Run/Replay:developers"
        - "Run/Update:developers"
```

### **Role-Based JCasC**
```yaml
jenkins:
  authorizationStrategy:
    roleBased:
      roles:
        global:
          - name: "admin"
            description: "Jenkins administrators"
            permissions:
              - "Overall/Administer"
            assignments:
              - "admin-group"
          - name: "developer"
            description: "Developers"
            permissions:
              - "Overall/Read"
              - "Job/Build"
              - "Job/Create"
              - "Job/Configure"
            assignments:
              - "dev-group"
```

## ⚠️ Authorization Troubleshooting

### **Permission Debugging**
```groovy
// Debug permission issues
import jenkins.model.*
import hudson.security.*

def debugPermission = { username, permission ->
    def user = User.get(username)
    def auth = user.impersonate()
    def hasPermission = Jenkins.instance.authorizationStrategy.rootACL
        .hasPermission(auth, permission)
    
    println "User: ${username}"
    println "Permission: ${permission.id}"
    println "Has Permission: ${hasPermission}"
    println "Groups: ${auth.authorities*.authority}"
}

debugPermission("testuser", Jenkins.READ)
```

### **Common Issues**
```bash
# Check user groups
curl -u admin:token "http://jenkins/user/username/api/json?pretty=true"

# Verify LDAP group membership
ldapsearch -x -H ldap://server -D "bind-dn" -w password \
  -b "search-base" "(&(objectClass=user)(sAMAccountName=username))" memberOf
```

## 📋 Authorization Best Practices

### **Security Guidelines**
- [ ] Principle of least privilege
- [ ] Regular permission audits
- [ ] Group-based permissions
- [ ] Separate admin accounts
- [ ] Project-level isolation
- [ ] Time-based restrictions
- [ ] Permission documentation
- [ ] Regular access reviews