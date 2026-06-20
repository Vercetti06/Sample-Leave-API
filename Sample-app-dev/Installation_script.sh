#!/bin/bash

# Exit immediately if any command fails
set -e

echo "================================================================="
echo "1/5: Updating System and Installing Core Dependencies (Java 21)..."
echo "================================================================="
sudo apt-get update -y
sudo apt-get install -y openjdk-21-jdk apt-transport-https gnupg2 curl ca-certificates

echo "================================================================="
echo "2/5: Installing Docker Engine..."
echo "================================================================="
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
echo "docker installation completed"

echo "================================================================="
echo "3/5: Installing Kubernetes CLI (kubectl) & Minikube..."
echo "================================================================="
#kubectl CLI installation
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
rm kubectl
echo "kubectl installation completed"

echo "-----------------------------------------------------------------------------------------------------------------------------------"

#minikube installation
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

echo "================================================================="
echo "4/5: Installing Host-Based Jenkins..."
# FORCE CLEAN: Wipe out any old, broken, or misconfigured files (e.g., www.jenkins.io)
sudo rm -f /etc/apt/sources.list.d/jenkins*

# Download the updated 2026 Jenkins release key to the secure directory
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

# Inject the modern, authentic repository path mapping
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Rebuild package list from scratch and execute native installation
sudo apt-get clean
sudo apt-get update -y
sudo apt-get install jenkins -y

# Explicitly bind Jenkins service to the Java 21 directory path
sudo mkdir -p /etc/systemd/system/jenkins.service.d
echo -e "[Service]\nEnvironment=\"JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64\"" | sudo tee /etc/systemd/system/jenkins.service.d/override.conf > /dev/null

# Add jenkins system user to the docker group
sudo usermod -aG docker jenkins

# Reset failure counters, reload definitions, and start the engine cleanly
sudo systemctl reset-failed jenkins
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl restart jenkins

echo "================================================================="
echo "5/5: Starting Minikube and Linking Cluster Configs to Jenkins..."
echo "================================================================="
# We use 'sg docker' here so minikube can start using the docker driver 
# without requiring you to log out and log back in right now.
minikube start

#enabling metrics server for HPA ressource
minikube addons enable metrics-server
kubectl get pods -n kube-system | grep metrics-server

#enabling ingress 
minikube addons enable ingress
kubectl get pods -n ingress-nginx

echo "Syncing Kubernetes certificates to Jenkins service account..."
# Create configuration paths inside Jenkins home directory
sudo mkdir -p /var/lib/jenkins/.kube
sudo mkdir -p /var/lib/jenkins/.minikube

# Copy active config maps and internal verification keys
sudo cp -r ~/.kube/config /var/lib/jenkins/.kube/config
sudo cp -r ~/.minikube/ca.crt /var/lib/jenkins/.minikube/ca.crt
sudo cp -r ~/.minikube/profiles /var/lib/jenkins/.minikube/profiles

# Fix hardcoded paths inside the copied Jenkins kubeconfig to point to its own home folder
sudo sed -i "s|/home/ubuntu|/var/lib/jenkins|g" /var/lib/jenkins/.kube/config

# Align ownership permissions exclusively to the Jenkins service user
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube /var/lib/jenkins/.minikube

# Restart Jenkins to securely inherit the new Docker group membership context
sudo systemctl restart jenkins

echo "================================================================="
echo "SETUP COMPLETED SUCCESSFULLY!"
echo "================================================================="
echo "1. Jenkins URL: http://YOUR_SERVER_IP:8080"
echo "2. Initial Unlock Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "-----------------------------------------------------------------"
echo "⚠️ IMPORTANT: Please run the following command manually in your"
echo "terminal right now to activate your local user's docker access:"
echo "     newgrp docker"
echo "================================================================="

