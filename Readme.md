## MEMP for Macs with Apple silicon chips 

## Overview
This script is written using the shell, in order to quickly deploy "LEMP" for Macs with Apple silicon chips (os: Bigsur, Monterey).

`M` - MacOS

`E` - Nginx

`M` - Mysql

`P` - PHP


##  Main function:

- Create vhost quickly with ssl and wildcard ssl for local domain, custom domain name, project path and php version of arbitrary project.
- Switch default PHP version with just 1 command line.
- Start, Stop, and Restart services quickly.
- View the list of available vhosts.

## How to setup
**NOTE:**  Require finish setting up command line developer tools before.

1 - Pull source code
- Clone MEMP repository inside `Desktop`
```
cd ~/Desktop
git clone https://github.com/xuandung38/MEMP.git
```
2 - Enter the project folder, give permissions to the install.sh file.
```
cd MEMP
sudo chmod +x install.sh
```

3 - Setup.

```
./install.sh
```

Note: Please enter password or use fingerprint (TouchID) to authenticate when required to be able to install!

## Infomations

- Local Dir like mamp pro:

```
~/Sites
```

- Default domain is `.web`

```
ex: hxd.web
```

Thanks to @ronilaukkarinen for idea

Give me start if this script helpful.
