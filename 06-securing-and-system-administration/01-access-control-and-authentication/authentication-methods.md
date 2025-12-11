# Authentication Methods

## 🔐 Authentication Overview

Jenkins supports multiple authentication methods to integrate with existing organizational security infrastructure.

## 🏠 Jenkins Own User Database

### **Basic Setup**
```
Security Realm: Jenkins' own user database
Allow users to sign up: ✓ (for initial setup only)
```

### **User Management**
```groovy
// Create user programmatically
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("username", "password")
instance.setSecurityRealm(hudsonRealm)
instance.save()
```

## 🌐 LDAP Authentication

### **Active Directory Configuration**
```
Server: ldap://ad.company.com:389
Root DN: DC=company,DC=com
User search base: CN=Users,DC=company,DC=com
User search filter: sAMAccountName={0}
Group search base: CN=Users,DC=company,DC=com
Group search filter: (& (cn={0}) (objectclass=group))
Manager DN: CN=jenkins,CN=Users,DC=company,DC=com
Manager Password: [service-account-password]
```

### **OpenLDAP Configuration**
```
Server: ldap://openldap.company.com:389
Root DN: dc=company,dc=com
User search base: ou=people,dc=company,dc=com
User search filter: uid={0}
Group search base: ou=groups,dc=company,dc=com
Group search filter: (& (cn={0}) (objectclass=posixGroup))
Manager DN: cn=admin,dc=company,dc=com
```

### **LDAP Testing Script**
```groovy
// Test LDAP connection
import javax.naming.*
import javax.naming.directory.*

def env = new Hashtable()
env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory")
env.put(Context.PROVIDER_URL, "ldap://ad.company.com:389")
env.put(Context.SECURITY_AUTHENTICATION, "simple")
env.put(Context.SECURITY_PRINCIPAL, "CN=jenkins,CN=Users,DC=company,DC=com")
env.put(Context.SECURITY_CREDENTIALS, "password")

try {
    def ctx = new InitialDirContext(env)
    println "LDAP connection successful"
    ctx.close()
} catch (Exception e) {
    println "LDAP connection failed: ${e.message}"
}
```

## 🔑 SAML Authentication

### **SAML Plugin Configuration**
```xml
<!-- SAML Configuration -->
<saml2>
  <idpMetadataConfiguration>
    <url>https://sso.company.com/metadata</url>
  </idpMetadataConfiguration>
  <spEntityId>jenkins.company.com</spEntityId>
  <displayNameAttributeName>displayName</displayNameAttributeName>
  <groupsAttributeName>groups</groupsAttributeName>
  <usernameAttributeName>username</usernameAttributeName>
  <emailAttributeName>email</emailAttributeName>
</saml2>
```

### **SAML Attributes Mapping**
```
Username Attribute: username
Display Name Attribute: displayName
Email Attribute: email
Groups Attribute: groups
```

## 🔐 OAuth Authentication

### **GitHub OAuth**
```
GitHub Web Application:
Client ID: [github-client-id]
Client Secret: [github-client-secret]
OAuth Scope: read:org,user:email
```

### **Google OAuth**
```
Google OAuth:
Client ID: [google-client-id]
Client Secret: [google-client-secret]
Domain: company.com
```

### **OAuth Configuration Script**
```groovy
// Configure GitHub OAuth
import org.jenkinsci.plugins.GithubSecurityRealm
import jenkins.model.Jenkins

def githubRealm = new GithubSecurityRealm(
    "https://github.com",
    "https://api.github.com",
    "client-id",
    "client-secret",
    "read:org,user:email"
)

Jenkins.instance.setSecurityRealm(githubRealm)
Jenkins.instance.save()
```

## 🎫 Kerberos Authentication

### **Kerberos Setup**
```
Kerberos Realm: COMPANY.COM
KDC Server: kdc.company.com
Service Principal: HTTP/jenkins.company.com@COMPANY.COM
Keytab File: /etc/jenkins/jenkins.keytab
```

### **Keytab Generation**
```bash
# Generate keytab file
ktutil
addent -password -p HTTP/jenkins.company.com@COMPANY.COM -k 1 -e aes256-cts
write_kt /etc/jenkins/jenkins.keytab
quit

# Set permissions
chown jenkins:jenkins /etc/jenkins/jenkins.keytab
chmod 600 /etc/jenkins/jenkins.keytab
```

## 🔒 Multi-Factor Authentication

### **TOTP Plugin Configuration**
```groovy
// Enable TOTP for users
import jenkins.security.plugins.ldap.*
import org.jenkinsci.plugins.otp.*

def totpAuth = new TOTPAuthentication()
totpAuth.setEnabled(true)
totpAuth.save()
```

### **SMS Authentication**
```
SMS Provider: Twilio
Account SID: [twilio-sid]
Auth Token: [twilio-token]
From Number: +1234567890
```

## 🔐 API Token Authentication

### **Personal Access Tokens**
```groovy
// Generate API token for user
import jenkins.model.Jenkins
import hudson.model.User

def user = User.get("username")
def apiToken = user.getProperty(jenkins.security.ApiTokenProperty.class)
def token = apiToken.generateNewToken("automation-token")
println "Generated token: ${token.plainValue}"
```

### **Service Account Tokens**
```bash
# Create service account
curl -X POST "http://jenkins.company.com/user/service-account/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" \
  --user admin:password \
  --data "newTokenName=ci-cd-token"
```

## 🔧 Custom Authentication Realm

### **Custom Security Realm**
```java
public class CustomSecurityRealm extends AbstractPasswordBasedSecurityRealm {
    
    @Override
    protected UserDetails authenticate(String username, String password) 
            throws AuthenticationException {
        // Custom authentication logic
        if (customAuthService.authenticate(username, password)) {
            return new User(username, password, true, true, true, true, 
                          getAuthorities(username));
        }
        throw new BadCredentialsException("Invalid credentials");
    }
    
    @Override
    public UserDetails loadUserByUsername(String username) 
            throws UsernameNotFoundException {
        // Load user details from custom source
        return customUserService.loadUser(username);
    }
}
```

## 📊 Authentication Monitoring

### **Login Audit Script**
```groovy
// Monitor authentication events
import jenkins.security.SecurityListener
import hudson.model.User

SecurityListener.all().add(new SecurityListener() {
    @Override
    void authenticated(UserDetails details) {
        println "User authenticated: ${details.username} at ${new Date()}"
    }
    
    @Override
    void failedToAuthenticate(String username) {
        println "Failed authentication: ${username} at ${new Date()}"
    }
})
```

### **Failed Login Tracking**
```groovy
// Track failed logins
def failedLogins = [:]

def trackFailedLogin = { username ->
    failedLogins[username] = (failedLogins[username] ?: 0) + 1
    if (failedLogins[username] > 5) {
        println "ALERT: Multiple failed logins for ${username}"
    }
}
```

## ⚠️ Troubleshooting Authentication

### **Common LDAP Issues**
```bash
# Test LDAP connectivity
ldapsearch -x -H ldap://ad.company.com:389 \
  -D "CN=jenkins,CN=Users,DC=company,DC=com" \
  -w password \
  -b "DC=company,DC=com" \
  "(sAMAccountName=testuser)"
```

### **Debug Authentication**
```
# Enable debug logging
Logger: hudson.security
Level: FINE

Logger: org.springframework.security
Level: DEBUG
```

### **Authentication Test Script**
```groovy
// Test authentication methods
import jenkins.model.Jenkins
import org.springframework.security.authentication.*

def authManager = Jenkins.instance.securityRealm.securityComponents.manager
def token = new UsernamePasswordAuthenticationToken("username", "password")

try {
    def result = authManager.authenticate(token)
    println "Authentication successful: ${result.principal}"
} catch (Exception e) {
    println "Authentication failed: ${e.message}"
}
```

## 📋 Authentication Best Practices

### **Security Checklist**
- [ ] Use external authentication (LDAP/SAML)
- [ ] Enable MFA for admin accounts
- [ ] Regular password policy enforcement
- [ ] Monitor failed login attempts
- [ ] Use service accounts for automation
- [ ] Regular token rotation
- [ ] Audit authentication logs
- [ ] Disable unused authentication methods