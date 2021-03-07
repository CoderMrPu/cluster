#!/usr/bin/env bash


if [[ -f /home/vagrant/.features/apache2 ]]; then
    echo "Apache2 already installed."
    exit 0
fi

sudo touch /home/vagrant/.features/apache2
sudo chown -Rf vagrant:vagrant /home/vagrant/.features

sudo apt-get install apache2 -y

