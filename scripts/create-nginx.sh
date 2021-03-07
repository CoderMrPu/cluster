#!/usr/bin/env bash

block="# cluster information configuration

upstream $1 {
  ${2}
}

server {
  listen       80;
  server_name  $1;

  location / {
    proxy_pass http://$1;
    proxy_redirect off;
  }
}
"
echo "$block" > "/etc/nginx/sites-available/$1.conf"
#sudo ln -fs "/etc/nginx/sites-available/$1.conf" "/etc/nginx/sites-enabled/$1.conf"

sudo service nginx restart