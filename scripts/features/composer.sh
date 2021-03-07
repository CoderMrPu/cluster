#!/usr/bin/env bash


if [[ -f /home/vagrant/.features/composer ]]; then
    echo "Composer already installed."
    exit 0
fi

sudo touch /home/vagrant/.features/composer
sudo chown -Rf vagrant:vagrant /home/vagrant/.features

sudo apt-get install composer -y
