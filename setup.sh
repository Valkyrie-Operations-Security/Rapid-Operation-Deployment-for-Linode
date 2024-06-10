#!/bin/bash
 
# Setup for linode deployment
# Ensures needed tools are installed
sudo apt update

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update
sudo apt install terraform

# Install Ansible
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# Install Linode-CLI
pip3 install linode-cli --upgrade

# Install OpenSSL
sudo apt install openssl

# Install Jq
sudo apt install jq
