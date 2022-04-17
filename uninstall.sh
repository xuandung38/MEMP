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
brew services stop dnsmasq
brew services stop redis
brew services stop mysql
brew uninstall nginx
brew uninstall --ignore-dependencies php@7.4
brew uninstall --ignore-dependencies php@8.0
brew uninstall --ignore-dependencies php@8.1
brew uninstall dnsmasq
brew uninstall redis
brew uninstall mysql
sudo rm /opt/homebrew/etc/dnsmasq.conf
sudo rm -rf /etc/resolver
sudo rm -rf sudo rm -rf /opt/homebrew/Cellar/dnsmasq
sudo rm -rf /opt/homebrew/Cellar/redis
sudo rm -rf /opt/homebrew/etc/php
sudo rm -rf /opt/homebrew/Cellar/nginx
brew cleanup

echo "${boldgreen}Remove MEMP Success${txtreset}"
