#!/bin/bash

# Check for updates
sudo apt update

# Install golang, make, git, mingw-w64
sudo apt-get install -y golang-go build-essential git mingw-w64 curl unzip zip

# Make a sliver directory
sudo mkdir /opt/sliver

# Change directory
cd /opt/sliver

# Install sliver
sudo curl https://sliver.sh/install|sudo bash
