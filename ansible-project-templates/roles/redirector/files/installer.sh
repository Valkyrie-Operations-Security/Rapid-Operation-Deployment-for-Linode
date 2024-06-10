#!/bin/bash

# Install certbot and the nginx add-on
apt-get install certbot python3-certbot-nginx

# Get SSL Cert from Let's Encrypt
# certbot --nginx -d example.com -d www.example.com
