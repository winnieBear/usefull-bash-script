sudo pacman -S nginx php php-fpm mariadb

sudo mkdir -p /home/www/blog

sudo cp nginx.conf /etc/nginx

sudo cp php.ini /etc/php

sudo cp php-fpm.conf /etc/php/

sudo cp blog.conf /etc/php/php-fpm.d

sudo systemctl enable nginx php-fpm
sudo systemctl restart nginx php-fpm
