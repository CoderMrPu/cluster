#!/usr/bin/env bash

if [[ -f /home/vagrant/.features/mysql8 ]]; then
    echo "MySQL 8 already installed."
    exit 0
fi

sudo apt-get update -y

sudo touch /home/vagrant/.features/mysql8
sudo chown -Rf vagrant:vagrant /home/vagrant/.features

sudo apt-get install mysql-server -y

sudo cat > /etc/mysql/mysql.conf.d/mysqld.cnf << EOF
[mysqld]
bind-address = 0.0.0.0
default_authentication_plugin = mysql_native_password
EOF

sudo service mysql restart

mysql --user="root" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';"
mysql --user="root" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
mysql --user="root" -e "CREATE USER 'cluster'@'0.0.0.0' IDENTIFIED BY 'password';"
mysql --user="root" -e "CREATE USER 'cluster'@'%' IDENTIFIED BY 'password';"
mysql --user="root" -e "GRANT ALL PRIVILEGES ON *.* TO 'cluster'@'0.0.0.0' WITH GRANT OPTION;"
mysql --user="root" -e "GRANT ALL PRIVILEGES ON *.* TO 'cluster'@'%' WITH GRANT OPTION;"
mysql --user="root" -e "FLUSH PRIVILEGES;"

sudo service mysql restart

echo -e "\e[31mAccount information[username:root,password:password][username:cluster,password:password]\e[0m"