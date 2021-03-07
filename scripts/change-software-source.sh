#!/usr/bin/env bash

if [[ "${1}" != "https://mirrors.aliyun.com/ubuntu" ]]; then
  if [[ -f /etc/apt/sources.list.backup ]]; then
    sudo rm -Rf /etc/apt/sources.list

    sudo cp /etc/apt/sources.list.backup /etc/apt/sources.list
  fi

  sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

  sudo sed -i "s/https://mirrors.aliyun.com/ubuntu/$1/g" /etc/apt/sources.list
fi
