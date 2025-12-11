# What is a Pipeline?

## 🔄 Pipeline Definition

A Jenkins Pipeline is a suite of plugins that supports implementing and integrating continuous delivery pipelines into Jenkins through code.

## 🏗️ Pipeline Analogy

Think of a pipeline like a **car manufacturing assembly line**:

```
Raw Materials → Welding → Painting → Assembly → Quality Check → Finished Car
     ↓             ↓         ↓          ↓           ↓             ↓
Source Code → Build → Test → Package → Deploy → Running App
```

## 📝 Pipeline as Code

### **Traditional Approach (Freestyle Jobs)**
- Manual configuration through Jenkins UI
- Not version controlled
- Difficult to replicate

### **Pipeline Approach (Jenkinsfile)**
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Deploy') {
            steps {
                sh 'mvn deploy'
            }
        }
    }
}
```

## 🎯 Key Pipeline Concepts

### **1. Stages**
Logical divisions of work in your pipeline

### **2. Steps**
Individual tasks within a stage

### **3. Agent**
Where the pipeline runs

## 🔧 Pipeline Types

### **1. Declarative Pipeline**
- Structured syntax
- Easier to read
- Built-in error handling
- Recommended approach

### **2. Scripted Pipeline**
- Groovy-based
- More flexible
- Requires more expertise
- Legacy approach