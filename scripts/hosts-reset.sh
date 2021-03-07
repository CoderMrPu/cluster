#!/usr/bin/env bash

sudo sed -i '/#### HOMESTEAD-SITES-BEGIN/,/#### HOMESTEAD-SITES-END/d' /etc/hosts

printf "#### HOMESTEAD-SITES-BEGIN\n#### HOMESTEAD-SITES-END\n" | sudo tee -a /etc/hosts > /dev/null
