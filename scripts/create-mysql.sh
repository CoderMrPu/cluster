#!/usr/bin/env bash

cat > /root/.my.cnf << EOF
[client]
user = cluster
password = password
host = localhost
EOF

cp /root/.my.cnf /home/vagrant/.my.cnf

mysql -e "CREATE DATABASE IF NOT EXISTS \`$1\` DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci";
