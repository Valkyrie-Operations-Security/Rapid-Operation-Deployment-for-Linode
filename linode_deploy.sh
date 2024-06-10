#!/bin/bash
#Dakota - Valkyire Operations Leader Operator
#v1.0 - 6/9/2024

# Clears screen
clear

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Checks for an ansible-project folder
if [[ ! -d "ansible-project" ]]; then
  mkdir "ansible-project"
fi

# Clean ansible-project to ensure a clean Run
echo "Cleaning any previous run"
rm -rf ansible-project/*
echo "Cleaning complete"

# Copy ansible-project templates
echo "Copying Ansible Templates"
cp -r ansible-project-templates/* ansible-project
echo "Copy Complete"

# Starting check message
echo "Checking for necessary build tools"

# Check if Terraform is installed
echo "Checking for Terraform"
if ! command_exists terraform; then
  echo "Terraform is not installed. Please install Terraform and try again."
  exit 1
fi

# Check if OpenSSL is installed
echo "Checking for OpenSSL"
if ! command_exists openssl; then
  echo "OpenSSL is not installed. Please install OpenSSL and try again."
  exit 1
fi

# Check if Ansible is installed
echo "Checking for Ansible"
if ! command_exists ansible-playbook; then
  echo "Ansible is not installed. Please install Ansible and try again."
  exit 1
fi

# Check if Linode-cli is installed
echo "Checking for Linode-CLI"
if ! command_exists linode-cli; then
  echo "Linode-cli is not installed. Please install Linode-cli and try again."
  exit 1
fi

# Check jq is installed
echo "Checking for jq"
if ! command_exists jq; then
  echo "jq is not installed. Please install jq and try again."
  exit 1
fi
echo "All tools found" 

# Remove old linode deployment
if [[ -f "linode_teamserver_deploy.tf" ]]; then
  echo "Cleaning old linode deployment"
  rm linode_teamserver_deploy.tf
fi

# Copy deployment template over old file
echo "Copying Linode deployment template"
cp linode_deploy_template linode_teamserver_deploy.tf

# Check if linode_teamserver_deploy.tf is in the current working directory
if [[ ! -f "linode_teamserver_deploy.tf" ]]; then
  echo "File linode_teamserver_deploy.tf not found in the current working directory."
  exit 1
fi

# Prompt user for Linode access token
read -rp "Enter your Linode access token: " LINODE_ACCESS_TOKEN

# Set up Linode-cli
export LINODE_CLI_TOKEN=$LINODE_ACCESS_TOKEN
linode-cli configure --token

# Store users public ip
USER_PUBLIC_IP=$(curl -s ifconfig.co)

# Prompt user for cobaltstrike license key for updating
read -rp "Enter license for cobaltstrike: " COBALT_LICENSE

# Predefined list of regions supporting both Linodes and VPCs
declare -A supported_regions=(
    ["nl-ams"]="Amsterdam, Netherlands"
    ["in-maa"]="Chennai, India"
    ["us-ord"]="Chicago, IL, USA"
    ["id-cgk"]="Jakarta, Indonesia"
    ["us-lax"]="Los Angeles, CA, USA"
    ["us-mia"]="Miami, FL, USA"
    ["it-mil"]="Milan, Italy"
    ["fr-par"]="Paris, France"
    ["jp-osa"]="Osaka, Japan"
    ["br-gru"]="São Paulo, Brazil"
    ["us-sea"]="Seattle, WA, USA"
    ["se-sto"]="Stockholm, Sweden"
    ["us-iad"]="Washington DC, USA"
)

# Display regions as a numbered list
echo "Available regions:"
i=1
declare -A region_map
for key in "${!supported_regions[@]}"; do
    echo "$i. ${supported_regions[$key]} ($key)"
    region_map[$i]=$key
    ((i++))
done

# Prompt the user to choose a region
read -p "Enter the number or region ID: " choice

# Determine if the choice is a number or region ID
if [[ $choice =~ ^[0-9]+$ ]] && [ ! -z ${region_map[$choice]} ]; then
    # If numeric and valid index
    region_id=${region_map[$choice]}
elif [[ -n "${supported_regions[$choice]}" ]]; then
    # If direct region ID and exists in the list
    region_id=$choice
else
    echo "Invalid selection."
    exit 1
fi

# Generate a random 16 character password for root
PASSWORD=$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9@#$%^&*()_+|~' | head -c 16)

# Generate a random 16 character password for pwndrop
PWN_PASS=$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9@#$%^&*()_+|~' | head -c 16)

# Generate a random 16 character username for pwndrop
PWN_ADMIN=$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 16)

# Generate a random 16 character directory for pwndrop
PWN_DIR=$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 16)

# Generate a random 12 character name for the vpc
VPC_NAME=$(openssl rand -base64 24 | tr -dc 'A-Za-z' | head -c 16)

# Check for ssh-keys directory, create if it doesn't exist
SSH_KEYS_DIR="ssh-keys"
if [[ ! -d "$SSH_KEYS_DIR" ]]; then
  mkdir "$SSH_KEYS_DIR"
fi

# Check for id_rsa and id_rsa.pub, create if they don't exist
if [[ -f "$SSH_KEYS_DIR/id_rsa" || -f "$SSH_KEYS_DIR/id_rsa.pub" ]]; then
  echo "Clearing old SSH Keys"
  rm -rf ssh-keys/id_rsa*
  echo "Creating new SSH Keys"
  ssh-keygen -t rsa -b 2048 -f "$SSH_KEYS_DIR/id_rsa" -N ""
  chmod 600 ssh-keys/id_rsa
fi

# Check for id_rsa and id_rsa.pub, create if they don't exist
if [[ ! -f "$SSH_KEYS_DIR/id_rsa" || ! -f "$SSH_KEYS_DIR/id_rsa.pub" ]]; then
  echo "Creating new SSH Keys"
  ssh-keygen -t rsa -b 2048 -f "$SSH_KEYS_DIR/id_rsa" -N ""
  chmod 600 ssh-keys/id_rsa
fi

# Replace <insert_token_here> with the provided access token in the Terraform file
sed -i "s/<insert_token_here>/$LINODE_ACCESS_TOKEN/g" linode_teamserver_deploy.tf

# Replace <password> with the generated password in the Terraform file
sed -i "s/<password>/$PASSWORD/g" linode_teamserver_deploy.tf

# Replace <op_ip> with the users public ip
sed -i "s/<op_ip>/$USER_PUBLIC_IP/g" linode_teamserver_deploy.tf

# Replace <vpc_name> with the generated vpc name
sed -i "s/<vpc_name>/$VPC_NAME/g" linode_teamserver_deploy.tf

# Replace <node_region> with the selected region id
sed -i "s/<node_region>/$region_id/g" linode_teamserver_deploy.tf

# Replace <cobalt_license> in the cobaltstrike installer script
sed -i "s/<cobalt_license>/$COBALT_LICENSE/g" ansible-project/roles/cobaltstrike/files/installer.sh

# Replace pwndrop admin password in the installer script
sed -i "s/<pwn_password>/$PWN_PASS/g" ansible-project/roles/pwndrop/files/installer.sh

# Replace pwndrop admin in the installer script
sed -i "s/<pwn_admin>/$PWN_ADMIN/g" ansible-project/roles/pwndrop/files/installer.sh

# Replace pwndrop directory in the installer script
sed -i "s/<pwn_path>/$PWN_DIR/g" ansible-project/roles/pwndrop/files/installer.sh

# Check for cobaltstrike tar file
echo "Checking for password protected cobaltstrike.tgz in: ansible-project/roles/cobaltstrike/files/"
if [[ ! -f "ansible-project/roles/cobaltstrike/files/cobaltstrike-dist.tgz" ]]; then
  echo "Cobaltstrike not found, please add cobaltstrike.tgz to ansible-project-templates/roles/cobaltstrike/files/"
  exit 1
fi

# Deploy Server
terraform init
terraform apply -auto-approve

# Sleep to wait for server deployment
echo "Sleeping for 30 seconds to allow time for servers to stand up"
sleep 30

# Fetch all Linodes and their IPs as JSON
export LINODE_CLI_TOKEN=$LINODE_ACCESS_TOKEN
linodes=$(linode-cli linodes list --json)

# Function to extract the public IP from the list of IPs
function extract_ip {
    local ips=("$@")
    echo "${ips[0]}"
}

# Extract IPs for each server and assign to variables
REDIRECTOR_IP=$(extract_ip "$(echo $linodes | jq -r '.[] | select(.label=="redirector") | .ipv4[]')")
COBALTSTRIKE_IP=$(extract_ip "$(echo $linodes | jq -r '.[] | select(.label=="cobaltstrike") | .ipv4[]')")
SLIVER_IP=$(extract_ip "$(echo $linodes | jq -r '.[] | select(.label=="sliver") | .ipv4[]')")
PWNDROP_IP=$(extract_ip "$(echo $linodes | jq -r '.[] | select(.label=="pwndrop") | .ipv4[]')")

# Set public IPs in Ansible Host file
sed -i "s/<redirect_ip>/$REDIRECTOR_IP/g" ansible-project/inventory/hosts.yaml
sed -i "s/<cobalt_ip>/$COBALTSTRIKE_IP/g" ansible-project/inventory/hosts.yaml
sed -i "s/<sliver_ip>/$SLIVER_IP/g" ansible-project/inventory/hosts.yaml
sed -i "s/<pwndrop_ip>/$PWNDROP_IP/g" ansible-project/inventory/hosts.yaml

# Move to the ansible project 
cd ansible-project 

# Run ansible
ansible-playbook -i inventory/hosts.yaml site.yaml --private-key=../ssh-keys/id_rsa

# Output the generated password to the terminal
echo "Your generated Root password is: $PASSWORD"

# Output ssh key location to the terminal
echo "Your ssh keys have been generated and are in ./ssh-keys"

# Output PwnDrop Admin, Password, directory
echo "Your generated PwnDrop admin is: $PWN_ADMIN"
echo "Your generated PwnDrop password is: $PWN_PASS"
echo "Your generated PwnDrop admin panel directory is: /$PWN_DIR"

# Print the variables for confirmation
echo "Redirector Public IP: $REDIRECTOR_IP"
echo "CobaltStrike Public IP: $COBALTSTRIKE_IP"
echo "Sliver Public IP: $SLIVER_IP"
echo "Pwndrop Public IP: $PWNDROP_IP"

# Output closing message
echo "Happy Hunting Operator"
