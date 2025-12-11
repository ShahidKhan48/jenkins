# Kubernetes + Helm Installation Guide

## Overview
This guide covers deploying Jenkins on Kubernetes using Helm charts, providing a production-ready, scalable Jenkins setup with high availability and cloud-native features.

## Prerequisites

### Kubernetes Cluster Requirements
```
┌─────────────────────────────────────────────────────────────┐
│              Kubernetes Prerequisites                       │
├─────────────────────────────────────────────────────────────┤
│ • Kubernetes cluster 1.19+                                 │
│ • kubectl configured and working                            │
│ • Helm 3.0+ installed                                       │
│ • Cluster admin permissions                                 │
│ • StorageClass for persistent volumes                       │
│ • LoadBalancer or Ingress controller                        │
│ • Minimum 4 CPU cores and 8GB RAM available                │
└─────────────────────────────────────────────────────────────┘
```

### Tool Installation Verification
```bash
# Verify Kubernetes cluster access
kubectl cluster-info
kubectl get nodes

# Verify Helm installation
helm version

# Check available storage classes
kubectl get storageclass

# Verify ingress controller (if using ingress)
kubectl get pods -n ingress-nginx
```

## Method 1: Official Jenkins Helm Chart

### Add Jenkins Helm Repository
```bash
# Add Jenkins Helm repository
helm repo add jenkins https://charts.jenkins.io

# Update Helm repositories
helm repo update

# Search for Jenkins charts
helm search repo jenkins
```

### Basic Jenkins Installation
```bash
# Create namespace for Jenkins
kubectl create namespace jenkins

# Install Jenkins with default values
helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set controller.serviceType=LoadBalancer
```

### Custom Values Configuration
```yaml
# jenkins-values.yaml
controller:
  # Jenkins controller configuration
  image: "jenkins/jenkins"
  tag: "lts"
  
  # Resource requirements
  resources:
    requests:
      cpu: "1000m"
      memory: "2Gi"
    limits:
      cpu: "2000m"
      memory: "4Gi"
  
  # JVM options
  javaOpts: "-Xms2048m -Xmx2048m"
  
  # Jenkins configuration
  jenkinsOpts: "--httpPort=8080"
  
  # Service configuration
  serviceType: ClusterIP
  servicePort: 8080
  
  # Ingress configuration
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hostName: jenkins.yourdomain.com
    tls:
      - secretName: jenkins-tls
        hosts:
          - jenkins.yourdomain.com
  
  # Security configuration
  admin:
    existingSecret: "jenkins-admin-secret"
    userKey: username
    passwordKey: password
  
  # Plugin installation
  installPlugins:
    - kubernetes:latest
    - workflow-job:latest
    - workflow-aggregator:latest
    - credentials-binding:latest
    - git:latest
    - configuration-as-code:latest
    - blueocean:latest
  
  # Configuration as Code
  JCasC:
    defaultConfig: true
    configScripts:
      welcome-message: |
        jenkins:
          systemMessage: "Welcome to Jenkins on Kubernetes!"
      security-config: |
        jenkins:
          securityRealm:
            local:
              allowsSignup: false
          authorizationStrategy:
            loggedInUsersCanDoAnything:
              allowAnonymousRead: false

# Persistent storage
persistence:
  enabled: true
  storageClass: "gp2"  # AWS EBS example
  size: "50Gi"
  accessMode: "ReadWriteOnce"

# Agent configuration
agent:
  enabled: true
  image: "jenkins/inbound-agent"
  tag: "latest"
  
  # Resource limits for agents
  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "1000m"
      memory: "2Gi"
  
  # Pod template for Kubernetes agents
  podTemplates:
    maven: |
      - name: maven
        label: maven
        serviceAccount: jenkins
        containers:
        - name: maven
          image: maven:3.8.1-openjdk-11
          command: "/bin/sh -c"
          args: "cat"
          ttyEnabled: true
          resourceRequestCpu: "500m"
          resourceRequestMemory: "1Gi"
          resourceLimitCpu: "1000m"
          resourceLimitMemory: "2Gi"
    docker: |
      - name: docker
        label: docker
        serviceAccount: jenkins
        containers:
        - name: docker
          image: docker:dind
          privileged: true
          command: "/bin/sh -c"
          args: "cat"
          ttyEnabled: true

# Service Account
serviceAccount:
  create: true
  name: jenkins
  annotations: {}

# RBAC
rbac:
  create: true
  readSecrets: true
```

### Install with Custom Values
```bash
# Install Jenkins with custom configuration
helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --values jenkins-values.yaml

# Upgrade existing installation
helm upgrade jenkins jenkins/jenkins \
  --namespace jenkins \
  --values jenkins-values.yaml
```

## Method 2: Advanced Production Setup

### High Availability Configuration
```yaml
# jenkins-ha-values.yaml
controller:
  # Multiple replicas for HA (requires shared storage)
  replicaCount: 2
  
  # Anti-affinity to spread pods across nodes
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - jenkins
        topologyKey: kubernetes.io/hostname
  
  # Node selector for dedicated nodes
  nodeSelector:
    node-type: jenkins-controller
  
  # Tolerations for tainted nodes
  tolerations:
  - key: "jenkins"
    operator: "Equal"
    value: "controller"
    effect: "NoSchedule"

# Shared storage for HA
persistence:
  enabled: true
  storageClass: "efs-sc"  # AWS EFS for shared storage
  size: "100Gi"
  accessMode: "ReadWriteMany"

# Load balancer configuration
service:
  type: LoadBalancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
```

### Security Hardening Configuration
```yaml
# jenkins-security-values.yaml
controller:
  # Security context
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    runAsNonRoot: true
  
  # Container security context
  containerSecurityContext:
    runAsUser: 1000
    runAsGroup: 1000
    runAsNonRoot: true
    readOnlyRootFilesystem: false
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL

# Network policies
networkPolicy:
  enabled: true
  internalAgents:
    allowed: true
  externalAgents:
    ipCIDR: "10.0.0.0/8"

# Pod Security Policy
podSecurityPolicy:
  enabled: true
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: 'docker/default,runtime/default'
    apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
```

## Method 3: GitOps with ArgoCD

### ArgoCD Application Manifest
```yaml
# jenkins-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: jenkins
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://charts.jenkins.io
    chart: jenkins
    targetRevision: 4.2.17
    helm:
      valueFiles:
      - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: jenkins
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

### GitOps Repository Structure
```
jenkins-gitops/
├── environments/
│   ├── dev/
│   │   └── values.yaml
│   ├── staging/
│   │   └── values.yaml
│   └── prod/
│       └── values.yaml
├── base/
│   └── values.yaml
└── applications/
    ├── jenkins-dev.yaml
    ├── jenkins-staging.yaml
    └── jenkins-prod.yaml
```

## Method 4: Custom Helm Chart

### Create Custom Helm Chart
```bash
# Create new Helm chart
helm create jenkins-custom

# Chart structure
jenkins-custom/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   └── serviceaccount.yaml
└── charts/
```

### Custom Chart Templates

#### Deployment Template
```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "jenkins.fullname" . }}
  labels:
    {{- include "jenkins.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "jenkins.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "jenkins.selectorLabels" . | nindent 8 }}
    spec:
      serviceAccountName: {{ include "jenkins.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
      - name: {{ .Chart.Name }}
        securityContext:
          {{- toYaml .Values.securityContext | nindent 12 }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 8080
          protocol: TCP
        - name: agent
          containerPort: 50000
          protocol: TCP
        env:
        - name: JAVA_OPTS
          value: {{ .Values.javaOpts }}
        - name: JENKINS_OPTS
          value: {{ .Values.jenkinsOpts }}
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        {{- if .Values.casc.enabled }}
        - name: casc-config
          mountPath: /var/jenkins_home/casc_configs
        {{- end }}
        resources:
          {{- toYaml .Values.resources | nindent 12 }}
      volumes:
      - name: jenkins-home
        {{- if .Values.persistence.enabled }}
        persistentVolumeClaim:
          claimName: {{ include "jenkins.fullname" . }}
        {{- else }}
        emptyDir: {}
        {{- end }}
      {{- if .Values.casc.enabled }}
      - name: casc-config
        configMap:
          name: {{ include "jenkins.fullname" . }}-casc
      {{- end }}
```

## Kubernetes-Specific Configurations

### Jenkins Kubernetes Plugin Configuration
```yaml
# JCasC configuration for Kubernetes plugin
jenkins:
  clouds:
  - kubernetes:
      name: "kubernetes"
      serverUrl: "https://kubernetes.default"
      namespace: "jenkins"
      jenkinsUrl: "http://jenkins:8080"
      jenkinsTunnel: "jenkins-agent:50000"
      containerCapStr: "100"
      maxRequestsPerHostStr: "32"
      retentionTimeout: 5
      connectTimeout: 10
      readTimeout: 20
      
      templates:
      - name: "maven-agent"
        label: "maven"
        nodeUsageMode: EXCLUSIVE
        containers:
        - name: "maven"
          image: "maven:3.8.1-openjdk-11"
          command: "/bin/sh -c"
          args: "cat"
          ttyEnabled: true
          resourceRequestCpu: "500m"
          resourceRequestMemory: "1Gi"
          resourceLimitCpu: "1000m"
          resourceLimitMemory: "2Gi"
        - name: "docker"
          image: "docker:dind"
          privileged: true
          command: "/bin/sh -c"
          args: "cat"
          ttyEnabled: true
        volumes:
        - hostPathVolume:
            hostPath: "/var/run/docker.sock"
            mountPath: "/var/run/docker.sock"
```

### RBAC Configuration
```yaml
# rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins
```

## Monitoring and Observability

### Prometheus Monitoring
```yaml
# prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: jenkins-prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'jenkins'
      static_configs:
      - targets: ['jenkins:8080']
      metrics_path: '/prometheus'
      params:
        format: ['prometheus']
```

### Grafana Dashboard
```json
{
  "dashboard": {
    "title": "Jenkins Kubernetes Dashboard",
    "panels": [
      {
        "title": "Build Queue Length",
        "type": "stat",
        "targets": [
          {
            "expr": "jenkins_queue_size_value"
          }
        ]
      },
      {
        "title": "Active Executors",
        "type": "stat",
        "targets": [
          {
            "expr": "jenkins_executor_count_value"
          }
        ]
      }
    ]
  }
}
```

## Backup and Disaster Recovery

### Backup Strategy
```bash
#!/bin/bash
# backup-jenkins-k8s.sh

NAMESPACE="jenkins"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

# Backup Jenkins configuration
kubectl get configmap jenkins-casc -n $NAMESPACE -o yaml > $BACKUP_DIR/jenkins-casc.yaml

# Backup secrets
kubectl get secret jenkins-admin-secret -n $NAMESPACE -o yaml > $BACKUP_DIR/jenkins-secrets.yaml

# Backup persistent volume data
kubectl exec -n $NAMESPACE deployment/jenkins -- tar czf - /var/jenkins_home > $BACKUP_DIR/jenkins-home.tar.gz

echo "Backup completed: $BACKUP_DIR"
```

### Disaster Recovery
```bash
#!/bin/bash
# restore-jenkins-k8s.sh

BACKUP_DIR=$1
NAMESPACE="jenkins"

if [ -z "$BACKUP_DIR" ]; then
    echo "Usage: $0 <backup_directory>"
    exit 1
fi

# Restore configuration
kubectl apply -f $BACKUP_DIR/jenkins-casc.yaml -n $NAMESPACE

# Restore secrets
kubectl apply -f $BACKUP_DIR/jenkins-secrets.yaml -n $NAMESPACE

# Scale down Jenkins
kubectl scale deployment jenkins --replicas=0 -n $NAMESPACE

# Wait for pods to terminate
kubectl wait --for=delete pod -l app.kubernetes.io/name=jenkins -n $NAMESPACE --timeout=300s

# Restore data
kubectl run restore-pod --image=alpine --rm -i --tty \
  --overrides='{"spec":{"containers":[{"name":"restore","image":"alpine","volumeMounts":[{"name":"jenkins-home","mountPath":"/var/jenkins_home"}]}],"volumes":[{"name":"jenkins-home","persistentVolumeClaim":{"claimName":"jenkins"}}]}}' \
  -- sh -c "cd /var/jenkins_home && tar xzf -" < $BACKUP_DIR/jenkins-home.tar.gz

# Scale up Jenkins
kubectl scale deployment jenkins --replicas=1 -n $NAMESPACE

echo "Restore completed"
```

## Troubleshooting

### Common Issues and Solutions

#### Pod Stuck in Pending State
```bash
# Check pod events
kubectl describe pod jenkins-xxx -n jenkins

# Check persistent volume claims
kubectl get pvc -n jenkins

# Check storage class
kubectl get storageclass

# Check node resources
kubectl describe nodes
```

#### Agent Connection Issues
```bash
# Check service endpoints
kubectl get endpoints jenkins -n jenkins

# Check network policies
kubectl get networkpolicy -n jenkins

# Test connectivity from agent pod
kubectl run test-pod --image=busybox --rm -i --tty -- nslookup jenkins.jenkins.svc.cluster.local
```

#### Performance Issues
```bash
# Check resource usage
kubectl top pods -n jenkins
kubectl top nodes

# Check logs
kubectl logs deployment/jenkins -n jenkins

# Check JVM metrics
kubectl exec deployment/jenkins -n jenkins -- jstat -gc 1
```

## Lab Exercises

### Exercise 1: Basic Helm Installation
1. Install Jenkins using official Helm chart
2. Access Jenkins through port-forward
3. Complete initial setup

### Exercise 2: Production Configuration
1. Create custom values.yaml file
2. Configure ingress and SSL
3. Set up persistent storage

### Exercise 3: Kubernetes Agents
1. Configure Kubernetes plugin
2. Create pod templates
3. Run builds on Kubernetes agents

### Exercise 4: Monitoring Setup
1. Deploy Prometheus and Grafana
2. Configure Jenkins metrics
3. Create monitoring dashboards

## Best Practices

### Security
- Use RBAC with minimal required permissions
- Enable network policies
- Use secrets for sensitive data
- Regular security updates

### Performance
- Right-size resource requests and limits
- Use node affinity for optimal placement
- Implement horizontal pod autoscaling
- Monitor resource usage

### Reliability
- Configure health checks
- Use persistent storage
- Implement backup strategy
- Test disaster recovery procedures

## Next Steps

After successful Kubernetes installation:
1. Configure Jenkins security
2. Set up CI/CD pipelines
3. Implement monitoring
4. Plan scaling strategy