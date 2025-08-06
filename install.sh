#!/bin/bash

# パッケージリストを更新
sudo apt-get update

# Dockerのインストール
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# Docker Composeのインストール
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 必要なディレクトリを作成
mkdir -p html db_data

# docker-compose.yml を作成
cat <<EOL > docker-compose.yml
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    ports:
      - "8000:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_NAME: wordpress_db
      WORDPRESS_DB_USER: wordpress_user
      WORDPRESS_DB_PASSWORD: your_strong_password
    volumes:
      - ./html:/var/www/html
    depends_on:
      - db

  db:
    image: mariadb:latest
    environment:
      MYSQL_ROOT_PASSWORD: your_root_password
      MYSQL_DATABASE: wordpress_db
      MYSQL_USER: wordpress_user
      MYSQL_PASSWORD: your_strong_password
    volumes:
      - ./db_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p\${MYSQL_ROOT_PASSWORD}"]
      timeout: 5s
      retries: 5
      start_period: 10s

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    ports:
      - "8080:80"
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: your_root_password
    depends_on:
      - db

networks:
  default:
    driver: bridge
EOL

# Dockerコンテナを起動
sudo /usr/local/bin/docker-compose up -d

echo "セットアップが完了しました。"
echo "WordPressは http://localhost:8000 でアクセスできます。"
echo "phpMyAdminは http://localhost:8080 でアクセスできます。"