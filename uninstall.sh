#!/bin/bash
# UnInstall MEMP on Applesilicon.
# Script by xuandung38

# Helpers:
txtbold=$(tput bold)
boldyellow=${txtbold}$(tput setaf 3)
boldgreen=${txtbold}$(tput setaf 2)
yellow=$(tput setaf 3)
green=$(tput setaf 2)
txtreset=$(tput sgr0)

echo "${boldgreen}Start${txtreset}"

brew services stop nginx
sudo brew services stop dnsmasq
brew services stop redis
brew services stop mysql
brew uninstall nginx
brew uninstall --ignore-dependencies php
brew uninstall dnsmasq
brew uninstall redis
brew uninstall mysql
sudo rm /opt/homebrew/etc/dnsmasq.conf
sudo rm /etc/resolver/local

echo "${boldgreen}Remove MEMP Success${txtreset}"
