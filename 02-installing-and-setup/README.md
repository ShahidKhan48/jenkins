# Module 02: Installation & Setup ⚙️

## Overview
This module provides comprehensive installation guides for Jenkins across different platforms and deployment methods, from local development to production-ready Kubernetes deployments.

## Learning Objectives
- Install Jenkins on various platforms (Docker, Kubernetes, Linux, macOS, Windows)
- Configure initial Jenkins setup and security
- Navigate and customize Jenkins dashboard
- Implement post-installation best practices
- Troubleshoot common installation issues

## Module Structure

### 1. system-requirements/
- Hardware and software prerequisites
- Java version compatibility
- Platform-specific requirements
- Capacity planning guidelines

### 2. docker-installation/
- Docker-based Jenkins deployment
- Docker Compose configurations
- Volume management and persistence
- Container networking setup

### 3. kubernetes-helm-installation/
- Kubernetes cluster preparation
- Helm chart deployment
- Persistent volume configuration
- Ingress and service setup

### 4. linux-installation/
- Package manager installation (apt, yum, dnf)
- Manual installation from WAR file
- Service configuration and management
- Firewall and security setup

### 5. macos-installation/
- Homebrew installation
- Manual installation methods
- Service management with launchd
- Development environment setup

### 6. windows-installation/
- Windows installer package
- Service configuration
- IIS integration (optional)
- PowerShell automation

### 7. initial-configuration/
- Setup wizard walkthrough
- Admin user creation
- Plugin installation
- Security configuration

### 8. dashboard-overview/
- Dashboard navigation and components
- Job management interface
- System monitoring views
- Customization options

### 9. post-installation-setup/
- Essential plugin installation
- Global tool configuration
- Agent setup preparation
- Backup configuration

### 10. troubleshooting-installation/
- Common installation issues
- Port conflicts resolution
- Permission problems
- Performance optimization

## Installation Decision Matrix

### Choose Your Installation Method
```
┌─────────────────────────────────────────────────────────────┐
│                Installation Decision Matrix                 │
├─────────────────────────────────────────────────────────────┤
│ Use Case                    │ Recommended Method            │
├─────────────────────────────┼───────────────────────────────┤
│ Development/Testing         │ Docker or macOS Homebrew      │
│ Production Single Instance  │ Linux Package Manager         │
│ Production High Availability│ Kubernetes with Helm          │
│ Windows Environment         │ Windows Installer             │
│ Cloud Deployment           │ Kubernetes or Cloud Templates │
│ Quick Evaluation           │ Docker                        │
└─────────────────────────────┴───────────────────────────────┘
```

## Prerequisites Checklist

### Common Requirements
- [ ] Java 8 or 11 (OpenJDK recommended)
- [ ] Minimum 2GB RAM (4GB+ recommended)
- [ ] 10GB+ disk space
- [ ] Network access for plugin downloads
- [ ] Administrative privileges for installation

### Platform-Specific Requirements
- [ ] **Docker**: Docker Engine 20.10+
- [ ] **Kubernetes**: Kubernetes 1.19+ cluster
- [ ] **Linux**: systemd-based distribution
- [ ] **macOS**: macOS 10.14+ (Mojave)
- [ ] **Windows**: Windows Server 2016+ or Windows 10

## Estimated Time Requirements

### Installation Time by Method
```
┌─────────────────────────────────────────────────────────────┐
│ Installation Method         │ Setup Time │ Configuration    │
├─────────────────────────────┼────────────┼──────────────────┤
│ Docker (Simple)             │ 5 minutes  │ 15 minutes       │
│ Docker Compose (Advanced)   │ 15 minutes │ 30 minutes       │
│ Kubernetes + Helm           │ 30 minutes │ 45 minutes       │
│ Linux Package Manager       │ 10 minutes │ 20 minutes       │
│ macOS Homebrew             │ 10 minutes │ 15 minutes       │
│ Windows Installer          │ 15 minutes │ 25 minutes       │
└─────────────────────────────┴────────────┴──────────────────┘
```

## Security Considerations

### Initial Security Setup
- Enable security from the start
- Use strong admin passwords
- Configure HTTPS/SSL
- Implement proper firewall rules
- Regular security updates

### Production Security Checklist
- [ ] HTTPS/SSL certificate configured
- [ ] Strong authentication method (LDAP/SSO)
- [ ] Role-based access control
- [ ] Regular backup strategy
- [ ] Security plugin installation
- [ ] Audit logging enabled

## Quick Start Guide

### 1. Choose Installation Method
Select the most appropriate installation method based on your use case and environment.

### 2. Verify Prerequisites
Ensure all system requirements are met before beginning installation.

### 3. Follow Installation Guide
Use the detailed guides in each subdirectory for step-by-step instructions.

### 4. Complete Initial Setup
Run through the setup wizard and configure basic security settings.

### 5. Install Essential Plugins
Add necessary plugins for your specific use case and workflow.

### 6. Configure Dashboard
Customize the dashboard layout and views according to your preferences.

## Key Takeaways

After completing this module, you should be able to:
- ✅ Install Jenkins on any major platform
- ✅ Configure initial security and admin settings
- ✅ Navigate the Jenkins dashboard effectively
- ✅ Implement production-ready configurations
- ✅ Troubleshoot common installation issues
- ✅ Plan for scalability and high availability

## Next Steps

Once installation is complete, proceed to:
1. **Module 03: Basic Operations** - Learn day-to-day Jenkins usage
2. **Module 04: Pipelines** - Start building CI/CD pipelines
3. **Module 05: Advanced Features** - Explore enterprise capabilities

## Support Resources

- [Official Jenkins Installation Guide](https://www.jenkins.io/doc/book/installing/)
- [Docker Hub Jenkins Images](https://hub.docker.com/r/jenkins/jenkins)
- [Kubernetes Jenkins Helm Chart](https://github.com/jenkinsci/helm-charts)
- [Community Support Forums](https://community.jenkins.io/)