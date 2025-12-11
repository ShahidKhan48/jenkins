# Backup Strategies

## 💾 Backup Overview

Comprehensive backup strategies ensure Jenkins data protection and enable quick disaster recovery.

## 🎯 What to Backup

### **Critical Data**
```bash
# Essential Jenkins files
$JENKINS_HOME/config.xml                    # Global configuration
$JENKINS_HOME/jobs/*/config.xml            # Job configurations
$JENKINS_HOME/users/*/config.xml           # User configurations
$JENKINS_HOME/secrets/                      # Encryption keys
$JENKINS_HOME/plugins/                      # Installed plugins
$JENKINS_HOME/credentials.xml              # Stored credentials
```

### **Optional Data**
```bash
# Additional backup items
$JENKINS_HOME/builds/                       # Build history
$JENKINS_HOME/workspace/                    # Workspaces
$JENKINS_HOME/logs/                         # Log files
$JENKINS_HOME/fingerprints/                # Build fingerprints
```

## 🔄 Full System Backup

### **Complete Backup Script**
```bash
#!/bin/bash
# complete-backup.sh

JENKINS_HOME="/var/lib/jenkins"
BACKUP_DIR="/backup/jenkins"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="jenkins-full-${DATE}"

# Create backup directory
mkdir -p "${BACKUP_DIR}/${BACKUP_NAME}"

# Stop Jenkins service
sudo systemctl stop jenkins

# Create tar archive
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" \
    -C "$(dirname $JENKINS_HOME)" \
    "$(basename $JENKINS_HOME)" \
    --exclude="workspace" \
    --exclude="builds/*/workspace" \
    --exclude="*.tmp"

# Start Jenkins service
sudo systemctl start jenkins

# Verify backup
if [ -f "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" ]; then
    echo "Backup completed: ${BACKUP_NAME}.tar.gz"
    echo "Size: $(du -h ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz | cut -f1)"
else
    echo "Backup failed!"
    exit 1
fi

# Cleanup old backups (keep last 7 days)
find "${BACKUP_DIR}" -name "jenkins-full-*.tar.gz" -mtime +7 -delete
```

### **Docker Backup**
```bash
#!/bin/bash
# docker-backup.sh

CONTAINER_NAME="jenkins"
BACKUP_DIR="/backup/jenkins"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Stop container
docker stop "${CONTAINER_NAME}"

# Create volume backup
docker run --rm \
    -v jenkins_home:/source:ro \
    -v "${BACKUP_DIR}:/backup" \
    alpine:latest \
    tar -czf "/backup/jenkins-${DATE}.tar.gz" -C /source .

# Start container
docker start "${CONTAINER_NAME}"

echo "Docker backup completed: jenkins-${DATE}.tar.gz"
```

## ⚡ Incremental Backup

### **Configuration-Only Backup**
```bash
#!/bin/bash
# config-backup.sh

JENKINS_HOME="/var/lib/jenkins"
BACKUP_DIR="/backup/jenkins/config"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "${BACKUP_DIR}"

# Backup configurations only
tar -czf "${BACKUP_DIR}/config-${DATE}.tar.gz" \
    -C "${JENKINS_HOME}" \
    config.xml \
    jobs/*/config.xml \
    users/*/config.xml \
    secrets/ \
    credentials.xml \
    hudson.*.xml \
    jenkins.*.xml \
    org.jenkinsci.*.xml

echo "Configuration backup completed: config-${DATE}.tar.gz"
```

### **Differential Backup Script**
```bash
#!/bin/bash
# differential-backup.sh

JENKINS_HOME="/var/lib/jenkins"
BACKUP_DIR="/backup/jenkins/differential"
LAST_FULL_BACKUP="/backup/jenkins/last-full.timestamp"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "${BACKUP_DIR}"

# Find files modified since last full backup
if [ -f "${LAST_FULL_BACKUP}" ]; then
    REFERENCE_TIME=$(cat "${LAST_FULL_BACKUP}")
    
    find "${JENKINS_HOME}" \
        -newer "${REFERENCE_TIME}" \
        -type f \
        ! -path "*/workspace/*" \
        ! -path "*/builds/*/workspace/*" \
        ! -name "*.tmp" \
        -print0 | \
    tar -czf "${BACKUP_DIR}/diff-${DATE}.tar.gz" \
        --null -T -
        
    echo "Differential backup completed: diff-${DATE}.tar.gz"
else
    echo "No full backup reference found. Run full backup first."
    exit 1
fi
```

## 🗄️ Database Backup

### **H2 Database Backup**
```bash
#!/bin/bash
# h2-backup.sh

JENKINS_HOME="/var/lib/jenkins"
DB_DIR="${JENKINS_HOME}/fingerprints"
BACKUP_DIR="/backup/jenkins/database"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "${BACKUP_DIR}"

# Backup H2 database files
if [ -d "${DB_DIR}" ]; then
    tar -czf "${BACKUP_DIR}/h2-db-${DATE}.tar.gz" \
        -C "${JENKINS_HOME}" \
        fingerprints/
    
    echo "H2 database backup completed"
fi
```

### **External Database Backup**
```bash
#!/bin/bash
# postgres-backup.sh

DB_HOST="localhost"
DB_NAME="jenkins"
DB_USER="jenkins"
BACKUP_DIR="/backup/jenkins/database"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "${BACKUP_DIR}"

# PostgreSQL backup
pg_dump -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" \
    --no-password --clean --create \
    | gzip > "${BACKUP_DIR}/postgres-${DATE}.sql.gz"

echo "PostgreSQL backup completed: postgres-${DATE}.sql.gz"
```

## ☁️ Cloud Backup Solutions

### **AWS S3 Backup**
```bash
#!/bin/bash
# s3-backup.sh

JENKINS_HOME="/var/lib/jenkins"
S3_BUCKET="company-jenkins-backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="jenkins-${DATE}"

# Create local backup
tar -czf "/tmp/${BACKUP_NAME}.tar.gz" \
    -C "$(dirname $JENKINS_HOME)" \
    "$(basename $JENKINS_HOME)" \
    --exclude="workspace" \
    --exclude="builds/*/workspace"

# Upload to S3
aws s3 cp "/tmp/${BACKUP_NAME}.tar.gz" \
    "s3://${S3_BUCKET}/backups/${BACKUP_NAME}.tar.gz" \
    --storage-class STANDARD_IA

# Cleanup local backup
rm "/tmp/${BACKUP_NAME}.tar.gz"

# Set lifecycle policy for old backups
aws s3api put-bucket-lifecycle-configuration \
    --bucket "${S3_BUCKET}" \
    --lifecycle-configuration file://lifecycle-policy.json

echo "S3 backup completed: ${BACKUP_NAME}.tar.gz"
```

### **Lifecycle Policy (lifecycle-policy.json)**
```json
{
    "Rules": [
        {
            "ID": "JenkinsBackupLifecycle",
            "Status": "Enabled",
            "Filter": {
                "Prefix": "backups/"
            },
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "GLACIER"
                },
                {
                    "Days": 90,
                    "StorageClass": "DEEP_ARCHIVE"
                }
            ],
            "Expiration": {
                "Days": 2555
            }
        }
    ]
}
```

### **Azure Blob Storage Backup**
```bash
#!/bin/bash
# azure-backup.sh

JENKINS_HOME="/var/lib/jenkins"
STORAGE_ACCOUNT="companyjenkins"
CONTAINER_NAME="backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="jenkins-${DATE}.tar.gz"

# Create backup
tar -czf "/tmp/${BACKUP_NAME}" \
    -C "$(dirname $JENKINS_HOME)" \
    "$(basename $JENKINS_HOME)" \
    --exclude="workspace"

# Upload to Azure
az storage blob upload \
    --account-name "${STORAGE_ACCOUNT}" \
    --container-name "${CONTAINER_NAME}" \
    --name "${BACKUP_NAME}" \
    --file "/tmp/${BACKUP_NAME}" \
    --tier Cool

# Cleanup
rm "/tmp/${BACKUP_NAME}"

echo "Azure backup completed: ${BACKUP_NAME}"
```

## 🔄 Automated Backup Scheduling

### **Cron Configuration**
```bash
# /etc/crontab entries

# Full backup every Sunday at 2 AM
0 2 * * 0 jenkins /opt/jenkins/scripts/full-backup.sh

# Configuration backup daily at 1 AM
0 1 * * * jenkins /opt/jenkins/scripts/config-backup.sh

# Differential backup every 6 hours
0 */6 * * * jenkins /opt/jenkins/scripts/differential-backup.sh
```

### **Systemd Timer**
```ini
# /etc/systemd/system/jenkins-backup.timer
[Unit]
Description=Jenkins Backup Timer
Requires=jenkins-backup.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

```ini
# /etc/systemd/system/jenkins-backup.service
[Unit]
Description=Jenkins Backup Service
After=jenkins.service

[Service]
Type=oneshot
User=jenkins
ExecStart=/opt/jenkins/scripts/full-backup.sh
```

### **Jenkins Pipeline Backup**
```groovy
pipeline {
    agent any
    
    triggers {
        cron('0 2 * * 0') // Weekly on Sunday
    }
    
    stages {
        stage('Backup Jenkins') {
            steps {
                script {
                    def backupScript = '''
                        #!/bin/bash
                        JENKINS_HOME="/var/lib/jenkins"
                        BACKUP_DIR="/backup/jenkins"
                        DATE=$(date +%Y%m%d_%H%M%S)
                        
                        tar -czf "${BACKUP_DIR}/jenkins-${DATE}.tar.gz" \\
                            -C "$(dirname $JENKINS_HOME)" \\
                            "$(basename $JENKINS_HOME)" \\
                            --exclude="workspace"
                    '''
                    
                    writeFile file: 'backup.sh', text: backupScript
                    sh 'chmod +x backup.sh && ./backup.sh'
                }
            }
        }
        
        stage('Upload to S3') {
            steps {
                sh '''
                    aws s3 sync /backup/jenkins/ s3://company-jenkins-backups/ \\
                        --exclude "*" --include "jenkins-*.tar.gz"
                '''
            }
        }
        
        stage('Cleanup Old Backups') {
            steps {
                sh '''
                    find /backup/jenkins -name "jenkins-*.tar.gz" -mtime +7 -delete
                    aws s3 ls s3://company-jenkins-backups/ | \\
                        awk '$1 < "'$(date -d '30 days ago' '+%Y-%m-%d')'" {print $4}' | \\
                        xargs -I {} aws s3 rm s3://company-jenkins-backups/{}
                '''
            }
        }
    }
    
    post {
        success {
            emailext (
                subject: "Jenkins Backup Completed Successfully",
                body: "Jenkins backup completed at ${new Date()}",
                to: "admin@company.com"
            )
        }
        failure {
            emailext (
                subject: "Jenkins Backup Failed",
                body: "Jenkins backup failed at ${new Date()}. Please check logs.",
                to: "admin@company.com"
            )
        }
    }
}
```

## 🔍 Backup Verification

### **Backup Integrity Check**
```bash
#!/bin/bash
# verify-backup.sh

BACKUP_FILE="$1"
TEMP_DIR="/tmp/jenkins-verify-$$"

if [ ! -f "${BACKUP_FILE}" ]; then
    echo "Backup file not found: ${BACKUP_FILE}"
    exit 1
fi

# Create temporary directory
mkdir -p "${TEMP_DIR}"

# Extract backup
tar -xzf "${BACKUP_FILE}" -C "${TEMP_DIR}"

# Verify critical files
CRITICAL_FILES=(
    "config.xml"
    "secrets/master.key"
    "secrets/hudson.util.Secret"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [ ! -f "${TEMP_DIR}/jenkins/${file}" ]; then
        echo "ERROR: Critical file missing: ${file}"
        rm -rf "${TEMP_DIR}"
        exit 1
    fi
done

# Verify XML syntax
find "${TEMP_DIR}" -name "*.xml" -exec xmllint --noout {} \; 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Backup verification successful: ${BACKUP_FILE}"
else
    echo "WARNING: Some XML files may be corrupted"
fi

# Cleanup
rm -rf "${TEMP_DIR}"
```

### **Automated Verification**
```groovy
// Jenkins pipeline for backup verification
pipeline {
    agent any
    
    parameters {
        string(name: 'BACKUP_PATH', description: 'Path to backup file')
    }
    
    stages {
        stage('Verify Backup') {
            steps {
                script {
                    def backupPath = params.BACKUP_PATH
                    
                    // Extract and verify
                    sh """
                        mkdir -p /tmp/verify-\${BUILD_NUMBER}
                        tar -xzf ${backupPath} -C /tmp/verify-\${BUILD_NUMBER}
                        
                        # Check critical files
                        test -f /tmp/verify-\${BUILD_NUMBER}/jenkins/config.xml
                        test -f /tmp/verify-\${BUILD_NUMBER}/jenkins/secrets/master.key
                        
                        # Validate XML files
                        find /tmp/verify-\${BUILD_NUMBER} -name "*.xml" -exec xmllint --noout {} \\;
                        
                        # Cleanup
                        rm -rf /tmp/verify-\${BUILD_NUMBER}
                    """
                    
                    echo "Backup verification completed successfully"
                }
            }
        }
    }
}
```

## 📊 Backup Monitoring

### **Backup Status Dashboard**
```groovy
// Groovy script for backup monitoring
def checkBackupStatus = { ->
    def backupDir = new File('/backup/jenkins')
    def today = new Date()
    def yesterday = today - 1
    
    def todayBackups = backupDir.listFiles()?.findAll { file ->
        file.name.contains(today.format('yyyyMMdd'))
    }
    
    def status = [
        lastBackup: getLastBackupTime(backupDir),
        todayBackups: todayBackups?.size() ?: 0,
        totalSize: getTotalBackupSize(backupDir),
        oldestBackup: getOldestBackup(backupDir),
        status: todayBackups ? 'OK' : 'MISSING'
    ]
    
    return status
}

def getLastBackupTime = { dir ->
    def files = dir.listFiles()?.findAll { it.name.endsWith('.tar.gz') }
    return files ? files.max { it.lastModified() }.lastModified() : null
}

def status = checkBackupStatus()
println "Backup Status: ${status.status}"
println "Last Backup: ${new Date(status.lastBackup)}"
println "Today's Backups: ${status.todayBackups}"
```

## 📋 Backup Best Practices

### **Strategy Checklist**
- [ ] Regular full backups (weekly)
- [ ] Daily configuration backups
- [ ] Incremental/differential backups
- [ ] Off-site backup storage
- [ ] Backup encryption
- [ ] Automated verification
- [ ] Retention policies
- [ ] Recovery testing
- [ ] Documentation updates
- [ ] Monitoring and alerting