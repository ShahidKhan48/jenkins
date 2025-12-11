# Kubernetes Pod Failures

## 🚨 Pod Failure Overview

Kubernetes pod failures in Jenkins deployments can disrupt CI/CD workflows and require systematic troubleshooting.

## 🔍 Common Pod Failure Symptoms

### **Pod Status Issues**
```bash
# Check pod status
kubectl get pods -n jenkins

# Common failure states
NAME                    READY   STATUS             RESTARTS   AGE
jenkins-agent-abc123    0/1     ImagePullBackOff   0          5m
jenkins-agent-def456    0/1     CrashLoopBackOff   3          10m
jenkins-agent-ghi789    0/1     Pending            0          2m
```

### **Pod Events and Logs**
```bash
# Check pod events
kubectl describe pod jenkins-agent-abc123 -n jenkins

# View pod logs
kubectl logs jenkins-agent-abc123 -n jenkins

# Follow logs in real-time
kubectl logs -f jenkins-agent-abc123 -n jenkins
```

## 🖼️ Image Pull Issues

### **ImagePullBackOff Errors**
```yaml
# Common causes and solutions
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  2m                default-scheduler  Successfully assigned jenkins/jenkins-agent-abc123 to node1
  Normal   Pulling    1m (x4 over 2m)   kubelet            Pulling image "jenkins/agent:invalid-tag"
  Warning  Failed     1m (x4 over 2m)   kubelet            Failed to pull image "jenkins/agent:invalid-tag": rpc error: code = NotFound desc = failed to pull and unpack image
```

### **Image Pull Troubleshooting**
```bash
# Test image pull manually
docker pull jenkins/agent:latest

# Check image exists in registry
curl -s https://registry.hub.docker.com/v2/repositories/jenkins/agent/tags/ | jq '.results[].name'

# Verify registry authentication
kubectl get secret regcred -o yaml
```

### **Private Registry Authentication**
```yaml
# Create registry secret
apiVersion: v1
kind: Secret
metadata:
  name: regcred
  namespace: jenkins
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
---
# Pod template with image pull secret
apiVersion: v1
kind: Pod
spec:
  imagePullSecrets:
  - name: regcred
  containers:
  - name: jenkins-agent
    image: registry.company.com/jenkins/agent:latest
```

## 💥 CrashLoopBackOff Issues

### **Container Startup Failures**
```bash
# Check container exit codes
kubectl describe pod jenkins-agent-def456 -n jenkins

# Common exit codes:
# Exit Code 0: Success
# Exit Code 1: General errors
# Exit Code 125: Docker daemon error
# Exit Code 126: Container command not executable
# Exit Code 127: Container command not found
```

### **Memory and Resource Issues**
```yaml
# Resource limits causing crashes
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jenkins-agent
    image: jenkins/agent:latest
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "1Gi"
        cpu: "1000m"
```

### **Java Heap Issues**
```bash
# Check for OutOfMemoryError in logs
kubectl logs jenkins-agent-def456 -n jenkins | grep -i "outofmemory"

# Adjust JVM settings
env:
- name: JAVA_OPTS
  value: "-Xmx1g -Xms512m -XX:+UseG1GC"
```

## ⏳ Pending Pod Issues

### **Resource Constraints**
```bash
# Check node resources
kubectl describe nodes

# Check resource quotas
kubectl describe resourcequota -n jenkins

# Check limit ranges
kubectl describe limitrange -n jenkins
```

### **Node Selector Issues**
```yaml
# Pod with node selector
apiVersion: v1
kind: Pod
spec:
  nodeSelector:
    kubernetes.io/os: linux
    node-type: jenkins-agent
  containers:
  - name: jenkins-agent
    image: jenkins/agent:latest
```

### **Affinity and Anti-Affinity**
```yaml
# Pod affinity configuration
apiVersion: v1
kind: Pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: node-type
            operator: In
            values:
            - jenkins-agent
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - jenkins-agent
          topologyKey: kubernetes.io/hostname
```

## 🔐 Permission and Security Issues

### **ServiceAccount Problems**
```yaml
# Create service account for Jenkins
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-agent
  namespace: jenkins
---
# RBAC configuration
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: jenkins-agent-role
  namespace: jenkins
rules:
- apiGroups: [""]
  resources: ["pods", "pods/exec", "pods/log"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins-agent-binding
  namespace: jenkins
subjects:
- kind: ServiceAccount
  name: jenkins-agent
  namespace: jenkins
roleRef:
  kind: Role
  name: jenkins-agent-role
  apiGroup: rbac.authorization.k8s.io
```

### **Security Context Issues**
```yaml
# Pod security context
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
  containers:
  - name: jenkins-agent
    image: jenkins/agent:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
```

## 🌐 Network Issues

### **DNS Resolution Problems**
```bash
# Test DNS from pod
kubectl exec -it jenkins-agent-abc123 -n jenkins -- nslookup kubernetes.default

# Check DNS configuration
kubectl get configmap coredns -n kube-system -o yaml
```

### **Service Connectivity**
```bash
# Test service connectivity
kubectl exec -it jenkins-agent-abc123 -n jenkins -- curl jenkins-master:8080

# Check service endpoints
kubectl get endpoints jenkins-master -n jenkins
```

### **Network Policies**
```yaml
# Allow Jenkins agent communication
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: jenkins-agent-policy
  namespace: jenkins
spec:
  podSelector:
    matchLabels:
      app: jenkins-agent
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: jenkins-master
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: jenkins-master
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

## 🔧 Debugging Tools and Commands

### **Pod Debugging Commands**
```bash
# Get detailed pod information
kubectl get pod jenkins-agent-abc123 -n jenkins -o yaml

# Check pod events
kubectl get events --field-selector involvedObject.name=jenkins-agent-abc123 -n jenkins

# Debug pod startup
kubectl debug jenkins-agent-abc123 -n jenkins -it --image=busybox

# Execute commands in running pod
kubectl exec -it jenkins-agent-abc123 -n jenkins -- /bin/bash
```

### **Resource Monitoring**
```bash
# Monitor resource usage
kubectl top pods -n jenkins

# Check node capacity
kubectl describe node <node-name> | grep -A 5 "Allocated resources"

# Monitor pod metrics
kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/jenkins/pods
```

### **Log Analysis**
```bash
# Aggregate logs from multiple pods
kubectl logs -l app=jenkins-agent -n jenkins --tail=100

# Export logs for analysis
kubectl logs jenkins-agent-abc123 -n jenkins > pod-logs.txt

# Search for specific errors
kubectl logs jenkins-agent-abc123 -n jenkins | grep -i error
```

## 🛠️ Common Fixes

### **Pod Restart Script**
```bash
#!/bin/bash
# restart-failed-pods.sh

NAMESPACE="jenkins"

# Get failed pods
FAILED_PODS=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase=Failed -o jsonpath='{.items[*].metadata.name}')

for pod in $FAILED_PODS; do
    echo "Deleting failed pod: $pod"
    kubectl delete pod $pod -n $NAMESPACE
done

# Get pods in CrashLoopBackOff
CRASH_PODS=$(kubectl get pods -n $NAMESPACE -o jsonpath='{.items[?(@.status.containerStatuses[0].state.waiting.reason=="CrashLoopBackOff")].metadata.name}')

for pod in $CRASH_PODS; do
    echo "Restarting crashed pod: $pod"
    kubectl delete pod $pod -n $NAMESPACE
done
```

### **Resource Cleanup**
```bash
# Clean up completed pods
kubectl delete pods --field-selector=status.phase=Succeeded -n jenkins

# Clean up failed pods
kubectl delete pods --field-selector=status.phase=Failed -n jenkins

# Clean up evicted pods
kubectl get pods -n jenkins | grep Evicted | awk '{print $1}' | xargs kubectl delete pod -n jenkins
```

### **Pod Template Validation**
```groovy
// Jenkins pipeline to validate pod templates
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - sleep
    args:
    - 99d
"""
        }
    }
    stages {
        stage('Validate Pod Template') {
            steps {
                container('kubectl') {
                    script {
                        // Validate pod template syntax
                        sh 'kubectl apply --dry-run=client -f pod-template.yaml'
                        
                        // Check resource requirements
                        sh 'kubectl describe nodes | grep -A 5 "Allocated resources"'
                    }
                }
            }
        }
    }
}
```

## 📊 Monitoring and Alerting

### **Pod Health Monitoring**
```yaml
# Prometheus monitoring rules
groups:
- name: jenkins-pods
  rules:
  - alert: JenkinsPodCrashLooping
    expr: rate(kube_pod_container_status_restarts_total{namespace="jenkins"}[5m]) > 0
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Jenkins pod is crash looping"
      description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is restarting frequently"
  
  - alert: JenkinsPodPending
    expr: kube_pod_status_phase{namespace="jenkins", phase="Pending"} == 1
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "Jenkins pod stuck in pending state"
      description: "Pod {{ $labels.pod }} has been pending for more than 10 minutes"
```

### **Automated Recovery**
```yaml
# Kubernetes CronJob for pod cleanup
apiVersion: batch/v1
kind: CronJob
metadata:
  name: jenkins-pod-cleanup
  namespace: jenkins
spec:
  schedule: "*/15 * * * *"  # Every 15 minutes
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: jenkins-cleanup
          containers:
          - name: cleanup
            image: bitnami/kubectl:latest
            command:
            - /bin/sh
            - -c
            - |
              # Delete failed pods older than 1 hour
              kubectl get pods -n jenkins --field-selector=status.phase=Failed -o json | \
              jq -r '.items[] | select(.metadata.creationTimestamp | fromdateiso8601 < (now - 3600)) | .metadata.name' | \
              xargs -r kubectl delete pod -n jenkins
              
              # Delete completed pods older than 24 hours
              kubectl get pods -n jenkins --field-selector=status.phase=Succeeded -o json | \
              jq -r '.items[] | select(.metadata.creationTimestamp | fromdateiso8601 < (now - 86400)) | .metadata.name' | \
              xargs -r kubectl delete pod -n jenkins
          restartPolicy: OnFailure
```

## 📋 Troubleshooting Checklist

### **Image Issues**
- [ ] Verify image exists and tag is correct
- [ ] Check registry authentication
- [ ] Validate image pull secrets
- [ ] Test manual image pull
- [ ] Check network connectivity to registry

### **Resource Issues**
- [ ] Check node resource availability
- [ ] Verify resource requests and limits
- [ ] Check resource quotas and limits
- [ ] Monitor node capacity
- [ ] Validate pod scheduling constraints

### **Configuration Issues**
- [ ] Verify pod template syntax
- [ ] Check service account permissions
- [ ] Validate security contexts
- [ ] Review network policies
- [ ] Test DNS resolution

### **Runtime Issues**
- [ ] Check container logs for errors
- [ ] Monitor resource usage
- [ ] Verify environment variables
- [ ] Test application startup
- [ ] Check health and readiness probes