#!/usr/bin/env bash


if [[ -f /home/vagrant/.features/nginx ]]; then
    echo "Nginx already installed."
    exit 0
fi

sudo apt-get update -y

sudo touch /home/vagrant/.features/nginx
sudo chown -Rf vagrant:vagrant /home/vagrant/.features

sudo apt-get install nginx -y
