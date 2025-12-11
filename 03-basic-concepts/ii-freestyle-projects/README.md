# Freestyle Projects

## 🎯 Freestyle Project Overview

### What are Freestyle Projects?
- **Traditional Jenkins job type** for simple build tasks
- **GUI-based configuration** without code
- **Step-by-step build process** definition
- **Ideal for beginners** and simple workflows

### Key Characteristics
```
┌─────────────────────────────────────────────────────────────┐
│                Freestyle Project Features                  │
├─────────────────────────────────────────────────────────────┤
│ • Web UI configuration                                      │
│ • No coding required                                        │
│ • Plugin-based functionality                               │
│ • Sequential build steps                                    │
│ • Simple trigger mechanisms                                 │
│ • Basic parameter support                                   │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Creating Freestyle Projects

### Step-by-Step Creation
1. **Navigate to Jenkins Dashboard**
2. **Click "New Item"**
3. **Enter project name**
4. **Select "Freestyle project"**
5. **Click "OK"**

### Configuration Sections
```
┌─────────────────────────────────────────────────────────────┐
│              Freestyle Project Configuration               │
├─────────────────────────────────────────────────────────────┤
│ General Settings:                                           │
│ • Project name and description                              │
│ • Discard old builds policy                                 │
│ • GitHub project URL                                        │
│                                                             │
│ Source Code Management:                                     │
│ • Git/SVN repository configuration                          │
│ • Branch specifications                                     │
│ • Credentials setup                                         │
│                                                             │
│ Build Triggers:                                             │
│ • SCM polling schedule                                      │
│ • Webhook triggers                                          │
│ • Periodic builds                                           │
│                                                             │
│ Build Environment:                                          │
│ • Delete workspace before build                             │
│ • Use secret text/files                                     │
│ • Set build name                                            │
│                                                             │
│ Build Steps:                                                │
│ • Execute shell/batch commands                              │
│ • Invoke build tools (Maven, Gradle)                       │
│ • Run scripts                                               │
│                                                             │
│ Post-build Actions:                                         │
│ • Archive artifacts                                         │
│ • Publish test results                                      │
│ • Send notifications                                        │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Common Build Steps

### Shell/Batch Commands
```bash
# Linux/macOS Shell Commands
#!/bin/bash
echo "Starting build process..."
mvn clean compile
mvn test
mvn package
echo "Build completed successfully!"
```

```batch
REM Windows Batch Commands
@echo off
echo Starting build process...
mvn clean compile
mvn test
mvn package
echo Build completed successfully!
```

### Maven Integration
```xml
<!-- Maven build configuration -->
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.8.1</version>
            <configuration>
                <source>11</source>
                <target>11</target>
            </configuration>
        </plugin>
    </plugins>
</build>
```

### Gradle Integration
```groovy
// Gradle build configuration
apply plugin: 'java'
apply plugin: 'application'

repositories {
    mavenCentral()
}

dependencies {
    testImplementation 'junit:junit:4.13.2'
}

test {
    useJUnit()
    testLogging {
        events "passed", "skipped", "failed"
    }
}
```

## 🎯 Advanced Configuration

### Build Parameters
```
┌─────────────────────────────────────────────────────────────┐
│                   Parameter Types                          │
├─────────────────────────────────────────────────────────────┤
│ String Parameter:                                           │
│ • Name: BRANCH_NAME                                         │
│ • Default: main                                             │
│ • Description: Git branch to build                         │
│                                                             │
│ Choice Parameter:                                           │
│ • Name: ENVIRONMENT                                         │
│ • Choices: dev, staging, production                         │
│ • Description: Target deployment environment               │
│                                                             │
│ Boolean Parameter:                                          │
│ • Name: RUN_TESTS                                           │
│ • Default: true                                             │
│ • Description: Execute test suite                          │
└─────────────────────────────────────────────────────────────┘
```

### Environment Variables
```bash
# Using build parameters in shell scripts
echo "Building branch: $BRANCH_NAME"
echo "Target environment: $ENVIRONMENT"

if [ "$RUN_TESTS" = "true" ]; then
    echo "Running tests..."
    mvn test
else
    echo "Skipping tests..."
fi
```

## 🎯 Post-Build Actions

### Artifact Archiving
```
Files to archive: target/*.jar, dist/*.zip
Use default excludes: Yes
Archive artifacts only if build is successful: Yes
Fingerprint archived artifacts: Yes
```

### Test Result Publishing
```
Test result XMLs: target/surefire-reports/*.xml
Health report amplification factor: 1.0
Allow empty results: No
```

### Email Notifications
```
Recipients: $DEFAULT_RECIPIENTS, dev-team@company.com
Subject: Build $BUILD_STATUS - $PROJECT_NAME - $BUILD_NUMBER
Content: 
Build: $BUILD_NUMBER
Status: $BUILD_STATUS
Changes: $CHANGES
Console: $BUILD_URL/console
```

## 🎯 Best Practices

### Project Organization
- **Descriptive naming** conventions
- **Consistent folder structure**
- **Regular cleanup** of old builds
- **Documentation** in project description

### Build Optimization
- **Parallel execution** where possible
- **Incremental builds** for large projects
- **Artifact caching** strategies
- **Resource management**

### Security Considerations
- **Credential management** for sensitive data
- **Access control** configuration
- **Audit logging** enablement
- **Secure communication** protocols

---

*"Freestyle projects provide an intuitive starting point for Jenkins automation, perfect for simple builds and learning Jenkins fundamentals."*