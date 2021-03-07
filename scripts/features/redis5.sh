#!/usr/bin/env bash


if [[ -f /home/vagrant/.features/redis5 ]]; then
    echo "Redis5 Server already installed."
    exit 0
fi

sudo apt-get update -y

sudo touch /home/vagrant/.features/redis5
sudo chown -Rf vagrant:vagrant /home/vagrant/.features

sudo apt-get install redis-server -y

echo -e "\e[31mPlease modify the configuration of /etc/redis/redis.conf by yourself\e[0m"

#sudo cat > /etc/redis/redis.conf << EOF
#bind 0.0.0.0
#requirepass password
#EOF

#sudo service redis-server restart