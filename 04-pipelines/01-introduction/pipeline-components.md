# Pipeline Components

## 🧩 Core Components

### **1. Pipeline Block**
The root element that defines the entire pipeline
```groovy
pipeline {
    // All pipeline content goes here
}
```

### **2. Agent**
Specifies where the pipeline will run
```groovy
agent any
agent { label 'linux' }
agent { docker 'maven:3.8.1' }
```

### **3. Stages**
Contains a sequence of one or more stage directives
```groovy
stages {
    stage('Build') { /* ... */ }
    stage('Test') { /* ... */ }
    stage('Deploy') { /* ... */ }
}
```

### **4. Steps**
Contains one or more build steps
```groovy
steps {
    sh 'mvn clean compile'
    echo 'Build completed'
}
```

### **5. Post**
Defines actions to run at the end of pipeline execution
```groovy
post {
    always { /* Always run */ }
    success { /* On success */ }
    failure { /* On failure */ }
}
```

## 🔧 Optional Components

### **Environment**
Defines environment variables
```groovy
environment {
    MAVEN_OPTS = '-Xmx1024m'
    BUILD_VERSION = '1.0.0'
}
```

### **Tools**
Defines tools to auto-install
```groovy
tools {
    maven 'Maven-3.8.1'
    jdk 'JDK-11'
}
```

### **Parameters**
Defines build parameters
```groovy
parameters {
    string(name: 'BRANCH', defaultValue: 'main')
    booleanParam(name: 'DEPLOY', defaultValue: false)
}
```

### **Triggers**
Defines build triggers
```groovy
triggers {
    cron('H 2 * * *')
    pollSCM('H/5 * * * *')
}
```