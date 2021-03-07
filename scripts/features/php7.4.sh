#!/usr/bin/env bash

if [[ -f /home/vagrant/.features/php7.4 ]]; then
    echo "PHP7.4 already installed."
    exit 0
fi

sudo apt-get update -y

sudo touch /home/vagrant/.features/php7.4
sudo chown -Rf vagrant:vagrant /home/vagrant/.features

sudo apt-get install php7.4 php7.4-cli php7.4-common php7.4-gd php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-xml php-redis -y

sudo service apache2 restart