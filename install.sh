#!/bin/bash
# Install MEMP on Applesilicon.
# Script by xuandung38
# Thanks to ronilaukkarinen for your idea

# Helpers:
txtbold=$(tput bold)
boldyellow=${txtbold}$(tput setaf 3)
boldgreen=${txtbold}$(tput setaf 2)
yellow=$(tput setaf 3)
green=$(tput setaf 2)
txtreset=$(tput sgr0)


install_dependencies() {
    check=$((xcode-\select --install) 2>&1)
    echo $check
    str="xcode-select: note: install requested for command line developer tools"
    while [[ "$check" == "$str" ]];
    do
      osascript -e 'tell app "System Events" to display dialog "Warning: Xcode Command Line Tools Missing" buttons "OK" default button 1 with title "MEMP dependencies missing"'
      exit;  
    done

    which -s brew
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        echo "${yellow}Install homebrew.${txtreset}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "${green}Homebrew are installed.${txtreset}"
    fi
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    
    echo "${yellow}Update homebrew.${txtreset}"
    brew doctor
    brew update && brew upgrade

    which -s git
    if [[ $? != 0 ]] ; then
        echo "${boldyellow}Install Git!${txtreset}"
        brew install git
    fi

    which -s code
    if [[ $? != 0 ]] ; then
        echo "${boldyellow}Install Visual Studio Code!${txtreset}"
        brew install --cask visual-studio-code
    fi
}

install_mysql() {

    which -s mysql
    if [[ $? != 0 ]] ; then
        # Install mysql
        echo "${yellow}Install mysql.${txtreset}"
        brew install mysql

        brew services start mysql
        
        echo "${boldyellow}Config Mysql.${txtreset}"

        mysql_secure_installation
        
        brew services restart mysql

        echo "${boldgreen}Mysql installed and running.${txtreset}"
        
    else
        echo "${green}Mysql already installed.${txtreset}"
    fi

}

install_php() {

    # Install php

    echo "${yellow}Install PHP.${txtreset}"
    brew tap shivammathur/php
    brew install shivammathur/php/php@7.4
    brew install shivammathur/php/php@8.0
    brew install shivammathur/php/php@8.1
    brew unlink php
    brew link --overwrite --force php@7.4

    echo "${yellow}Config FPM.${txtreset}"
    sudo cp ./www.temp /opt/homebrew/etc/php/7.4/php-fpm.d/www.conf

    sed -i '' "s:{{user}}:$USER:" /opt/homebrew/etc/php/7.4/php-fpm.d/www.conf
    sed -i '' "s:{{php_version}}:7.4:" /opt/homebrew/etc/php/7.4/php-fpm.d/www.conf
    

    sudo cp ./www.temp /opt/homebrew/etc/php/8.0/php-fpm.d/www.conf

    sed -i '' "s:{{user}}:$USER:" /opt/homebrew/etc/php/8.0/php-fpm.d/www.conf
    sed -i '' "s:{{php_version}}:8.0:" /opt/homebrew/etc/php/8.0/php-fpm.d/www.conf

    sudo cp ./www.temp /opt/homebrew/etc/php/8.1/php-fpm.d/www.conf

    sed -i '' "s:{{user}}:$USER:" /opt/homebrew/etc/php/8.1/php-fpm.d/www.conf
    sed -i '' "s:{{php_version}}:8.1:" /opt/homebrew/etc/php/8.1/php-fpm.d/www.conf

    sudo killall php-fpm

    echo "${yellow}Install Xdebug.${txtreset}"
    pecl uninstall -r xdebug 
    pecl install xdebug
    sudo echo "
[xdebug]
xdebug.mode=debug
xdebug.client_port=9003
xdebug.idekey=PHPSTORM
;xdebug.start_with_request = yes" >> "/opt/homebrew/etc/php/7.4/php.ini"

    brew link --overwrite --force php@8.0
    pecl uninstall -r xdebug 
    pecl install xdebug
 
    sudo echo "
[xdebug]
xdebug.mode=debug
xdebug.client_port=9003
xdebug.idekey=PHPSTORM
;xdebug.start_with_request = yes" >> "/opt/homebrew/etc/php/8.0/php.ini"

    brew link --overwrite --force php@8.1
    pecl uninstall -r xdebug 
    pecl install xdebug
 
    sudo echo "
[xdebug]
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
        sudo brew services start dnsmasq
        sudo echo 'address=/.web/127.0.0.1' > /opt/homebrew/etc/dnsmasq.conf
        sudo mkdir -v /etc/resolver
        sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/web'
        sudo echo "${boldgreen}Dnsmasq installed and running.${txtreset}"

        sudo brew services restart dnsmasq
        
    else
        echo "${green}Dnsmasq already installed.${txtreset}"
    fi

}

install_nginx() {
    which -s nginx  
    if [[ $? != 0 ]] ; then
        # Install nginx
        echo "${yellow}Install nginx.${txtreset}"
        brew install nginx

        brew services start nginx
        echo "${boldgreen}Nginx installed and running.${txtreset}"
    else
        echo "${green}Nginx already installed.${txtreset}"
    fi
}

install_redis() {
    which -s redis  
    if [[ $? != 0 ]] ; then
        # Install redis
        echo "${yellow}Install Redis.${txtreset}"
        brew install redis

        brew services start redis
        echo "${boldgreen}Redis installed and running.${txtreset}"
    else
        echo "${green}Redis already installed.${txtreset}"
    fi
}

config() {
    
    echo "${yellow}Config local server.${txtreset}"
  
    which -s mkcert
    if [[ $? != 0 ]] ; then
        # Install mkcert
        echo "${yellow}Install mkcert.${txtreset}"  
        brew install mkcert
        brew install nss
    else
        echo "${green}Mkcert already installed.${txtreset}"
    fi

    sudo mkcert -install
  
    which -s composer
    if [[ $? != 0 ]] ; then
        # Install composer
        echo "${yellow}Install composer.${txtreset}"  
        brew install composer
    else
        echo "${green}Composer already installed.${txtreset}"
    fi

    sudo chmod -R 775 /opt/homebrew/etc/nginx
    sudo mkdir -p /opt/homebrew/etc/nginx/default
    sudo mkdir -p /opt/homebrew/etc/nginx/servers
    sudo mkdir -p /opt/homebrew/etc/nginx/ssl
    
    sudo mkcert -key-file /opt/homebrew/etc/nginx/ssl/localhost.key -cert-file /opt/homebrew/etc/nginx/ssl/localhost.crt "localhost"
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /opt/homebrew/etc/nginx/ssl/localhost.crt
   
    sudo cp /opt/homebrew/etc/nginx/nginx.conf /opt/homebrew/etc/nginx/nginx.conf.bak

    sudo cp -r ./nginx/ /opt/homebrew/etc/nginx

    sudo cp ./nginx.temp /opt/homebrew/etc/nginx/nginx.conf

    sed -i '' "s:{{user}}:$USER:" /opt/homebrew/etc/nginx/nginx.conf

    sudo brew services restart nginx

    echo "${boldgreen}Config ZSH!${txtreset}"
    
    if [ -f "$HOME/.zshrc" ]; then
        echo "Backup $HOME/.zshrc"
        sudo cp $HOME/.zshrc $HOME/.zshrc.bak
    fi

    sudo cat ./zsh.temp >> $HOME/.zshrc
    sudo mkdir -p $HOME/Sites
    sudo chown $USER:staff $HOME/Sites
    ln -ls $HOME/Sites $HOME/Desktop
    echo "${boldgreen}Config local server done!${txtreset}"


    code /opt/homebrew/etc/nginx

    open $HOME/Sites

    open https://localhost
}

install_dependencies
install_php
install_mysql
install_nginx
install_dnsmasq
install_redis
config

echo "${boldgreen}Install MEMP Server Done!${txtreset}"
echo
echo "${yellow}Please Restart Terminal and type ${boldgreen}memp_help${txtreset}${yellow} to know how to use Quick Command!${txtreset}"
