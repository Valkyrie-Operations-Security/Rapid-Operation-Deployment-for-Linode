#!/bin/bash

# Check for Updates
sudo apt update

# Install golang, make, git, mingw-w64
sudo apt-get install -y golang-go build-essential git mingw-w64 curl zip unzip

# Create pwndrop config directory
sudo mkdir /usr/local/pwndrop

# Move the pwndrop ini file to the new directory
sudo mv /tmp/pwndrop.ini /usr/local/pwndrop/pwndrop.ini

# Move to opt
cd /opt

# Download pwndrop
sudo git clone https://github.com/kgretzky/pwndrop.git

# Move into the pwndrop directory
cd pwndrop

# Build and install pwndrop
sudo make
sudo make install
