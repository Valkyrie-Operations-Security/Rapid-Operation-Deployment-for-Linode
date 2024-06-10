# Rapid Operation Deployment for Linode 
### This is a infrastructure as code framework.
The framework was written by Valkyrie Operations to speed up deployment of infrastrucure for Red Team Operations.

## How it works
Our infrastructure deployment for Linode works off a mix of Terraform and Ansible. The deployment script was designed to run on a linux distro. Testing was perfomred using Ubuntu 24.04 LTS. 

This framework operates under the assumption you have a valid Cobalt Strike License and are using Cobalt Strike in an operation you are deploying for.
Since our infrastrucure here exists as code you can simply just comment out or remove any Cobalt Strike reference in the code to use.\
\
Additionally this framework is writen for deployment of 4 Ubuntu 24.04 servers but can easily be expanding by extending the code. In its current configuration the following 4 servers are deployed:
- Redirector with NGINX
- Cobalt Strike Teamserver
- Sliver C2 Server
- PwnDrop file hosting server

## Requirements to run
In order to run the script you will need the following pieces of software installed:
- Terraform - [Terraform Install Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Ansible - [Ansible Install Guide](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu)
- Linode-CLI - [Linode-CLI Install Guide](https://www.linode.com/docs/products/tools/cli/guides/install/)
- OpenSSL
- jq
  
We have included a setup file (setup.sh) to save you some time on installing if you are using a ubuntu based system for running the deployment script.

## How to use it
Either download the latest release zip file or git clone

~~~
git clone https://github.com/ValkyrieOps-Dakota/Rapid-Operation-Deployment-Linode.git
cd Rapid-Operation-Deployment-Linode
chmod +x setup.sh
./setup.sh
~~~

copy your cobaltstrike-dist.tgz file to ansible-project-templates/roles/cobaltstrike/files/
then run

~~~
chmod +x linode_deploy.sh
./linode_deploy.sh
~~~

## Notes about the Redirector
The ansible playbook for setting up the redirector is configured for only installing nginx. There is an additional task in the playbook that is commented out that can be used to configure the nginx server more. There is an included install script that will install certbot as a starting point. 
