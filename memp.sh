#!/bin/bash

export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
export PATH="$HOME/.composer/vendor/bin:$PATH"
# Helpers:
txtbold=$(tput bold)
boldyellow=${txtbold}$(tput setaf 3)
boldgreen=${txtbold}$(tput setaf 2)
yellow=$(tput setaf 3)
green=$(tput setaf 2)
txtreset=$(tput sgr0)


# Alias restart services

alias nginx.start='sudo brew services start nginx'
alias nginx.stop='sudo brew services stop nginx'
alias nginx.restart='sudo brew services restart nginx'

alias dnsmasq.start='sudo brew services start dnsmasq'
alias dnsmasq.stop='sudo brew services stop dnsmasq'
alias dnsmasq.restart='sudo brew services restart dnsmasq'

alias mysql.start='sudo mysql.server start'
alias mysql.stop='sudo mysql.server stop'
alias mysql.restart='sudo mysql.server restart'

alias php74.start='sudo brew services start php@7.4'
alias php74.stop='sudo brew services stop php@7.4'
alias php74.restart='sudo brew services restart php@7.4'

alias php80.start='sudo brew services start php@8.0'
alias php80.stop='sudo brew services stop php@8.0'
alias php80.restart='sudo brew services restart php@8.0'

alias php81.start='sudo brew services start php@8.1'
alias php81.stop='sudo brew services stop php@8.1'
alias php81.restart='sudo brew services restart php@8.1'

alias memp.stop='mysql.stop && nginx.stop && php74.stop && php80.stop && php81.stop && dnsmasq.stop'
alias memp.start='mysql.start && nginx.start && php74.start && php80.start && php81.start && dnsmasq.start'
alias memp.restart='memp.stop && memp.start'

alias pa='php artisan'

# Make switching versions easy

function phpv() {
    brew unlink php
    brew link --overwrite --force "php@$1"
    # Alias php versions
    export PATH="$(brew --prefix php@$1)/bin:$PATH"
    
}

function vhost() {

    sudo cp /opt/homebrew/etc/nginx/default/default.temp /opt/homebrew/etc/nginx/servers/$1.conf

    sed -i '' "s:{{host}}:$1:" /opt/homebrew/etc/nginx/servers/$1.conf

    if [ "$2" ]; then
        sed -i '' "s:{{root}}:$HOME/Sites/$2:" /opt/homebrew/etc/nginx/servers/$1.conf
    else
        sed -i '' "s:{{root}}:$HOME/Sites/$1:" /opt/homebrew/etc/nginx/servers/$1.conf
    fi

    if [ "$3" ]; then
        sed -i '' "s:{{php_version}}:$3:" /opt/homebrew/etc/nginx/servers/$1.conf
    else
        sed -i '' "s:{{php_version}}:8.0:" /opt/homebrew/etc/nginx/servers/$1.conf
    fi

    vhostaddssl $1

    nginx.restart

    code /opt/homebrew/etc/nginx/servers/$1.conf
}

function vhostaddssl() {

    sudo mkcert -key-file /opt/homebrew/etc/nginx/ssl/$1.key -cert-file /opt/homebrew/etc/nginx/ssl/$1.crt "$1.web" "*.$1.web"

    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /opt/homebrew/etc/nginx/ssl/$1.crt
}

function vhoste() {
    sudo code /opt/homebrew/etc/nginx/servers/$1.conf
}

function vhostl() {
    ls -ll /opt/homebrew/etc/nginx/servers/
}

function memp_help() {
    # Display Help

    echo "${boldgreen}MEMP Quick Command!${txtreset}"
    echo
    echo "${green}nginx.start${txtreset} _________ Start Nginx."
    echo "${green}nginx.stop${txtreset} __________ Stop Nginx."
    echo "${green}nginx.restart${txtreset} _______ Restart Nginx."
    echo
    echo "${green}php74.start${txtreset} _________ Start php7.4-fpm."
    echo "${green}php74.stop${txtreset} __________ Stop  php7.4-fpm."
    echo "${green}php74.restart${txtreset} _______ Restart  php7.4-fpm."

    echo
    echo "${green}php80.start${txtreset} _________ Start php8.0-fpm."
    echo "${green}php80.stop${txtreset} __________ Stop  php8.0-fpm."
    echo "${green}php80.restart${txtreset} _______ Restart  php8.0-fpm."

    echo
    echo "${green}php81.start${txtreset} _________ Start php8.0-fpm."
    echo "${green}php81.stop${txtreset} __________ Stop  php8.0-fpm."
    echo "${green}php81.restart${txtreset} _______ Restart  php8.0-fpm."

    echo
    echo "${green}mysql.start${txtreset} _________ Start mysql."
    echo "${green}mysql.stop${txtreset} __________ Stop mysql."
    echo "${green}mysql.restart${txtreset} _______ Restart mysql."

    echo
    echo "${green}memp.start${txtreset} __________ Start Memp."
    echo "${green}memp.stop${txtreset} ___________ Stop Memp."
    echo "${green}memp.restart${txtreset} ________ Restart Memp."

    echo
    echo "${boldgreen}Syntax: ${green}phpv [php_version]${txtreset}"
    echo "options:"
    echo "${green}php_version${txtreset} _________ The version of php you want to change to(7.4 and 8.0)."

    echo "${yellow}Example : Change to php@8.0 version!${txtreset}"
    echo
    echo "${boldgreen}phpv 8.0${txtreset}"
    echo

    echo
    echo "${boldgreen}Syntax: ${green} vhost [domain] [root] [php_version]${txtreset}"
    echo "options:"
    echo "${green}domain${txtreset} __________ Domain for local virtual host."
    echo "${green}root${txtreset} ____________ Target for root dir in $HOME/Sites (optional) ."
    echo "${green}php_version${txtreset} _____ PHP version (optional) ."

    echo "${yellow}Example : You want to make a domain like hxd.web${txtreset}"
    echo "${yellow}          And root dir is $HOME/Sites/laravel/public${txtreset}"
    echo "${yellow}          And and php is version 8.0${txtreset}"
    echo
    echo "${boldgreen}vhost hxd laravel/public 8.0${txtreset}"
    echo
    echo
}
