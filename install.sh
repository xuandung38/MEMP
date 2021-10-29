#!/bin/bash
# Install MEMP on Applesilicon.
# Script by xuandung38
# Thanks to ronilaukkarinen for your idea

# Helpers:
txtbold=$(tput bold)
boldyellow=${txtbold}$(tput setaf 3)
boldgreen=${txtbold}$(tput setaf 2)ư
yellow=$(tput setaf 3)
green=$(tput setaf 2)
txtreset=$(tput sgr0)


install_dependencies() {
    echo "${yellow}Getting dependencies.${txtreset}"
    if type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
    test -d "${xpath}" && test -x "${xpath}" ; then
    echo "${green}Command Line Tools are installed.${txtreset}"
    else
    xcode-select --install
    fi

    which -s brew
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        echo "${yellow}Install homebrew.${txtreset}"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo "${green}Homebrew are installed.${txtreset}"
    fi

    echo "${yellow}Update homebrew.${txtreset}"
    brew doctor
    brew update && brew upgrade

}

install_mysql() {

    which -s mysql
    if [[ $? != 0 ]] ; then
        # Install mysql
        echo "${yellow}Install mysql.${txtreset}"
        brew install mysql

        sudo brew services start mysql
        
        echo "${boldgreen}Mysql installed and running.${txtreset}"
        
    else
        echo "${green}Mysql are installed.${txtreset}"
    fi

}

install_php() {

    # Install php

    echo "${yellow}Install PHP.${txtreset}"
    brew tap shivammathur/php
    brew install shivammathur/php/php@7.4
    brew install shivammathur/php/php@8.0
    brew unlink php
    brew link --overwrite --force php@7.4

    echo "${yellow}Config FPM.${txtreset}"
    sudo cp ./www.temp /opt/homebrew/etc/php/7.4/php-fpm.d/www.conf

    sed -i '' "s:{{user}}:$USER:" /opt/homebrew/etc/php/7.4/php-fpm.d/www.conf
    sed -i '' "s:{{port}}:9074:" /opt/homebrew/etc/php/7.4/php-fpm.d/www.conf
    

    sudo cp ./www.temp /opt/homebrew/etc/php/8.0/php-fpm.d/www.conf

    sed -i '' "s:{{user}}:$USER:" /opt/homebrew/etc/php/8.0/php-fpm.d/www.conf
    sed -i '' "s:{{port}}:9080:" /opt/homebrew/etc/php/8.0/php-fpm.d/www.conf

    sudo killall php-fpm

    echo "${yellow}Install Xdebug.${txtreset}"
    pecl uninstall -r xdebug 
    pecl install xdebug
    sudo echo "[xdebug]
    zend_extension="xdebug.so"
    xdebug.mode=debug
    xdebug.client_port=9003
    xdebug.idekey=PHPSTORM
    ;xdebug.start_with_request = yes" >> "/opt/homebrew/etc/php/7.4/php.ini"

    brew link --overwrite --force php@8.0
    pecl uninstall -r xdebug 
    pecl install xdebug

    sudo echo "[xdebug]
    zend_extension="xdebug.so"
    xdebug.mode=debug
    xdebug.client_port=9003
    xdebug.idekey=PHPSTORM
    ;xdebug.start_with_request = yes" >> "/opt/homebrew/etc/php/8.0/php.ini"


}

install_dnsmasq() {

    which -s dnsmasq
    if [[ $? != 0 ]] ; then
        # Install dnsmasq
        echo "${yellow}Install dnsmasq.${txtreset}"
        brew install dnsmasq
        sudo echo 'address=/.web/127.0.0.1' > /opt/homebrew/etc/dnsmasq.conf
        sudo mkdir -v /etc/resolver
        sudo echo "nameserver 127.0.0.1" > /etc/resolver/web
        sudo echo "${boldgreen}Dnsmasq installed and running.${txtreset}"

        sudo brew services start dnsmasq
        
    else
        echo "${green}Dnsmasq are installed.${txtreset}"
    fi

}

install_nginx() {
    which -s nginx  
    if [[ $? != 0 ]] ; then
        # Install nginx
        echo "${yellow}Install nginx.${txtreset}"
        brew tap homebrew/nginx
        brew install nginx

        sudo brew services start nginx
        echo "${boldgreen}Nginx installed and running.${txtreset}"
    else
        echo "${green}Nginx are installed.${txtreset}"
    fi
}

config()
{
    
    echo "${yellow}Config local server.${txtreset}"
  
    which -s brew
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        echo "${yellow}Install mkcert.${txtreset}"  
        brew install mkcert
        brew install nss
        
    else
        echo "${green}Mkcert are installed.${txtreset}"
    fi

    sudo mkcert -install

    sudo chmod -R 775 /opt/homebrew/etc/nginx
    sudo mkdir -p /opt/homebrew/etc/nginx/default
    sudo mkdir -p /opt/homebrew/etc/nginx/php
    sudo mkdir -p /opt/homebrew/etc/nginx/servers
    sudo mkdir -p /opt/homebrew/etc/nginx/ssl

    sudo cp /opt/homebrew/etc/nginx/nginx.conf /opt/homebrew/etc/nginx/nginx.conf.bak

    sudo cp -r ./nginx/ /opt/homebrew/etc/nginx

    sudo cp ./nginx.temp /opt/homebrew/etc/nginx/nginx2.conf

    sed -i '' "s:{{user}}:$USER:" /opt/homebrew/etc/nginx/nginx2.conf

    sudo cat ./zsh.temp >> $HOME/.zshrc
    
    echo "${boldgreen}Config local server done!${txtreset}"
}

install_dependencies
# install_php
# install_mysql
install_nginx
install_dnsmasq
config