#!/usr/bin/env bash

declare -A params=$6    # Create an associative array
declare -A headers=${9} # Create an associative array
paramsTXT=""
if [[ -n "$6" ]]; then
  for element in "${!params[@]}"; do
    paramsTXT="${paramsTXT}
        SetEnv ${element} \"${params[$element]}\""
  done
fi

headersTXT=""
if [[ -n "${9}" ]]; then
  for element in "${!headers[@]}"; do
    headersTXT="${headersTXT}
      Header always set ${element} \"${headers[$element]}\""
  done
fi

server_name=""
if [[ "${11}" == "false" ]]; then
  server_name="
ServerName $1
ServerAlias www.$1
"
fi

alias=""
if [[ -n "${12}" ]]; then
  alias="Alias ${12}  $2"
fi

block="<VirtualHost *:$3>
    ServerAdmin webmaster@localhost
    $server_name
    DocumentRoot "$2"
    $alias
    $paramsTXT
    $headersTXT

    <Directory "$2">
        AllowOverride All
        Require all granted
    </Directory>

    #LogLevel info ssl:warn

    ErrorLog \${APACHE_LOG_DIR}/$1-error.log
    CustomLog \${APACHE_LOG_DIR}/$1-access.log combined

    #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"

if [[ "${11}" == "false" ]]; then
  sudo echo "$block" >"/etc/apache2/sites-available/$1.conf"
  sudo ln -fs "/etc/apache2/sites-available/$1.conf" "/etc/apache2/sites-enabled/$1.conf"
else
  sudo echo "$block" >"/etc/apache2/sites-available/000-default.conf"
  sudo ln -fs "/etc/apache2/sites-available/000-default.conf" "/etc/apache2/sites-enabled/000-default.conf"
fi

# Assume user wants mode_rewrite support
sudo a2enmod rewrite

sudo service apache2 restart

if [[ $? == 0 ]]; then
  sudo service apache2 reload
fi
