#!/bin/bash

# Move to opt
cd /opt

# Unzip cobaltstrike
tar zxvf cobaltstrike-dist.tgz

# Check for Updates
sudo apt update

# Install golang, make, git, mingw-w64, openjdk
sudo apt-get install -y golang-go build-essential git mingw-w64 unzip
sudo apt-get install -y openjdk-11-jdk

# Set JDK 11 as default
update-java-alternatives -s java-1.11.0-openjdk-amd64

# Move to cobaltstrike directory
cd cobaltstrike

# Update Cobaltstrike
echo "<cobalt_license>" | ./update
