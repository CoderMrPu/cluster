#!/usr/bin/env bash

server_name="ServerName $1"

alias=""

# if the default site is configured
if [ -n "$4" ]; then
  server_name=""
fi
# if alias is configured
if [ -n "$5" ]; then
  alias="Alias /$5  $2"
fi

block="<VirtualHost *:$3>
    ServerAdmin webmaster@localhost
    $server_name
    DocumentRoot "$2"
    $alias

    ErrorLog /var/log/httpd/$1-error.log
    CustomLog /var/log/httpd/$1-access.log combined

    <Directory "$2">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

</VirtualHost>
"

echo "$block" > "/etc/httpd/sites-available/$1.conf"