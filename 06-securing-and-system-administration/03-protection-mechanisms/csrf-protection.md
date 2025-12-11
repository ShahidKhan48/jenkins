# CSRF Protection

## 🛡️ CSRF Protection Overview

Cross-Site Request Forgery (CSRF) protection prevents malicious websites from performing unauthorized actions on behalf of authenticated users.

## 🔒 Enabling CSRF Protection

### **Basic Configuration**
```
Manage Jenkins → Configure Global Security
☑ Prevent Cross Site Request Forgery exploits
Default Crumb Issuer: ☑ Enabled
```

### **Programmatic Configuration**
```groovy
import jenkins.model.*
import hudson.security.csrf.*

def instance = Jenkins.getInstance()
def crumbIssuer = new DefaultCrumbIssuer(true)
instance.setCrumbIssuer(crumbIssuer)
instance.save()

println "CSRF protection enabled"
```

## 🔑 Crumb Configuration

### **Default Crumb Issuer**
```groovy
import hudson.security.csrf.*

// Configure default crumb issuer
def crumbIssuer = new DefaultCrumbIssuer(true)
crumbIssuer.setExcludeClientIPFromCrumb(false)

Jenkins.getInstance().setCrumbIssuer(crumbIssuer)
```

### **Custom Crumb Issuer**
```java
public class CustomCrumbIssuer extends CrumbIssuer {
    
    @Override
    public String issueCrumb(StaplerRequest request) {
        // Custom crumb generation logic
        String sessionId = request.getSession().getId();
        String userAgent = request.getHeader("User-Agent");
        String clientIP = request.getRemoteAddr();
        
        return generateCrumb(sessionId, userAgent, clientIP);
    }
    
    @Override
    public boolean validateCrumb(StaplerRequest request, String submittedCrumb) {
        String expectedCrumb = issueCrumb(request);
        return MessageDigest.isEqual(
            expectedCrumb.getBytes(),
            submittedCrumb.getBytes()
        );
    }
}
```

## 🌐 API Integration

### **REST API with Crumb**
```bash
# Get crumb token
CRUMB=$(curl -u "username:password" \
  'http://jenkins.company.com/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')

# Use crumb in API call
curl -u "username:password" \
  -H "$CRUMB" \
  -X POST \
  "http://jenkins.company.com/job/my-job/build"
```

### **Python API Client**
```python
import requests
import xml.etree.ElementTree as ET

class JenkinsClient:
    def __init__(self, url, username, password):
        self.url = url
        self.auth = (username, password)
        self.session = requests.Session()
        self.crumb = self._get_crumb()
    
    def _get_crumb(self):
        crumb_url = f"{self.url}/crumbIssuer/api/xml"
        response = self.session.get(crumb_url, auth=self.auth)
        
        if response.status_code == 200:
            root = ET.fromstring(response.content)
            field = root.find('crumbRequestField').text
            value = root.find('crumb').text
            return {field: value}
        return {}
    
    def trigger_build(self, job_name, parameters=None):
        url = f"{self.url}/job/{job_name}/build"
        headers = self.crumb.copy()
        
        if parameters:
            url += "WithParameters"
            response = self.session.post(
                url, 
                auth=self.auth, 
                headers=headers, 
                data=parameters
            )
        else:
            response = self.session.post(
                url, 
                auth=self.auth, 
                headers=headers
            )
        
        return response.status_code == 201

# Usage
client = JenkinsClient(
    "http://jenkins.company.com", 
    "username", 
    "password"
)
client.trigger_build("my-job")
```

### **JavaScript/AJAX Integration**
```javascript
// Get crumb for AJAX requests
function getCrumb() {
    return fetch('/crumbIssuer/api/json')
        .then(response => response.json())
        .then(data => ({
            field: data.crumbRequestField,
            value: data.crumb
        }));
}

// Use crumb in AJAX request
async function triggerBuild(jobName) {
    const crumb = await getCrumb();
    
    const response = await fetch(`/job/${jobName}/build`, {
        method: 'POST',
        headers: {
            [crumb.field]: crumb.value,
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        credentials: 'same-origin'
    });
    
    return response.ok;
}
```

## 🔧 Advanced Configuration

### **Proxy Compatibility**
```groovy
// Configure for reverse proxy
System.setProperty(
    "jenkins.model.Jenkins.crumbIssuerProxyCompatibility", 
    "true"
)

// Custom crumb issuer for proxy
def crumbIssuer = new DefaultCrumbIssuer(false) {
    @Override
    protected String getClientIP(HttpServletRequest request) {
        // Check X-Forwarded-For header
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        // Check X-Real-IP header
        String xRealIP = request.getHeader("X-Real-IP");
        if (xRealIP != null && !xRealIP.isEmpty()) {
            return xRealIP;
        }
        
        return request.getRemoteAddr();
    }
}
```

### **Custom Validation Logic**
```groovy
import hudson.security.csrf.*

class EnhancedCrumbIssuer extends DefaultCrumbIssuer {
    
    EnhancedCrumbIssuer(boolean excludeClientIP) {
        super(excludeClientIP)
    }
    
    @Override
    public boolean validateCrumb(StaplerRequest request, String submittedCrumb) {
        // Additional validation logic
        if (!isValidSession(request)) {
            return false
        }
        
        if (!isValidUserAgent(request)) {
            return false
        }
        
        return super.validateCrumb(request, submittedCrumb)
    }
    
    private boolean isValidSession(StaplerRequest request) {
        HttpSession session = request.getSession(false)
        return session != null && !session.isNew()
    }
    
    private boolean isValidUserAgent(StaplerRequest request) {
        String userAgent = request.getHeader("User-Agent")
        return userAgent != null && !userAgent.contains("bot")
    }
}
```

## 🔍 Monitoring and Debugging

### **CSRF Failure Logging**
```groovy
import java.util.logging.*

// Enable CSRF logging
Logger crumbLogger = Logger.getLogger("hudson.security.csrf.DefaultCrumbIssuer")
crumbLogger.setLevel(Level.FINE)

// Custom handler for CSRF failures
Handler crumbHandler = new Handler() {
    @Override
    public void publish(LogRecord record) {
        if (record.getMessage().contains("CSRF")) {
            // Log CSRF failures to security log
            securityLogger.warning("CSRF validation failed: ${record.getMessage()}")
            
            // Optional: Alert security team
            alertSecurityTeam(record)
        }
    }
}

crumbLogger.addHandler(crumbHandler)
```

### **CSRF Metrics Collection**
```groovy
// Collect CSRF metrics
class CSRFMetrics {
    private static int validRequests = 0
    private static int invalidRequests = 0
    private static Map<String, Integer> failureReasons = [:]
    
    static void recordValidRequest() {
        validRequests++
    }
    
    static void recordInvalidRequest(String reason) {
        invalidRequests++
        failureReasons[reason] = (failureReasons[reason] ?: 0) + 1
    }
    
    static Map getMetrics() {
        return [
            valid: validRequests,
            invalid: invalidRequests,
            failureReasons: failureReasons,
            successRate: validRequests / (validRequests + invalidRequests) * 100
        ]
    }
}
```

## 🛠️ Troubleshooting CSRF Issues

### **Common Problems**
```groovy
// Debug CSRF issues
def debugCSRF = { request ->
    def crumbIssuer = Jenkins.instance.crumbIssuer
    
    if (!crumbIssuer) {
        return "CSRF protection is disabled"
    }
    
    def expectedCrumb = crumbIssuer.issueCrumb(request)
    def submittedCrumb = request.getHeader(crumbIssuer.crumbRequestField)
    
    println "Expected crumb: ${expectedCrumb}"
    println "Submitted crumb: ${submittedCrumb}"
    println "Crumb field: ${crumbIssuer.crumbRequestField}"
    println "Client IP: ${request.getRemoteAddr()}"
    println "User Agent: ${request.getHeader('User-Agent')}"
    
    return crumbIssuer.validateCrumb(request, submittedCrumb)
}
```

### **Bypass for Specific Endpoints**
```groovy
// Bypass CSRF for specific API endpoints
import hudson.security.csrf.*

class SelectiveCrumbIssuer extends DefaultCrumbIssuer {
    
    private static final Set<String> BYPASS_PATHS = [
        "/github-webhook/",
        "/bitbucket-hook/",
        "/generic-webhook-trigger/"
    ] as Set
    
    SelectiveCrumbIssuer(boolean excludeClientIP) {
        super(excludeClientIP)
    }
    
    @Override
    public boolean validateCrumb(StaplerRequest request, String submittedCrumb) {
        String requestURI = request.getRequestURI()
        
        // Bypass CSRF for webhook endpoints
        if (BYPASS_PATHS.any { requestURI.startsWith(it) }) {
            return true
        }
        
        return super.validateCrumb(request, submittedCrumb)
    }
}
```

## 🔒 Security Best Practices

### **Configuration Recommendations**
```groovy
// Secure CSRF configuration
def secureCrumbIssuer = new DefaultCrumbIssuer(false) // Include client IP
Jenkins.instance.setCrumbIssuer(secureCrumbIssuer)

// Additional security headers
System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", 
    "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'")
```

### **Testing CSRF Protection**
```bash
#!/bin/bash
# Test CSRF protection

JENKINS_URL="http://jenkins.company.com"
USERNAME="testuser"
PASSWORD="testpass"

# Test without crumb (should fail)
echo "Testing without crumb..."
curl -u "$USERNAME:$PASSWORD" \
  -X POST \
  "$JENKINS_URL/job/test-job/build" \
  -w "Status: %{http_code}\n"

# Test with crumb (should succeed)
echo "Testing with crumb..."
CRUMB=$(curl -u "$USERNAME:$PASSWORD" \
  "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

curl -u "$USERNAME:$PASSWORD" \
  -H "$CRUMB" \
  -X POST \
  "$JENKINS_URL/job/test-job/build" \
  -w "Status: %{http_code}\n"
```

## 📋 CSRF Protection Checklist

### **Implementation**
- [ ] Enable CSRF protection
- [ ] Configure appropriate crumb issuer
- [ ] Test API integrations
- [ ] Update automation scripts
- [ ] Configure proxy compatibility
- [ ] Set up monitoring

### **Maintenance**
- [ ] Regular security testing
- [ ] Monitor CSRF failures
- [ ] Update client libraries
- [ ] Review bypass rules
- [ ] Security audit logs
- [ ] Performance monitoring