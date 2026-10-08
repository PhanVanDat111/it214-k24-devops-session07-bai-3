#!/bin/bash

# Exit on any error
set -e

echo "=== Step 1: Create Linux User 'spring-runner' ==="
if id "spring-runner" &>/dev/null; then
    echo "User 'spring-runner' already exists."
else
    sudo useradd -r -s /sbin/nologin spring-runner
    echo "User 'spring-runner' created successfully."
fi

echo "=== Step 2: Configure Directory and Permissions ==="
sudo mkdir -p /opt/spring-app
sudo touch /opt/spring-app/app.jar
sudo chown -R spring-runner:spring-runner /opt/spring-app

echo "=== Step 3: Setup MySQL Database & User ==="
# Setting up mysql configuration
sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS springboot_db;"
sudo mysql -u root -e "CREATE USER IF NOT EXISTS 'spring-admin'@'localhost' IDENTIFIED BY 'SpringSecure@123';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON springboot_db.* TO 'spring-admin'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
echo "MySQL user and database established."

echo "=== Step 4: Deploy Systemd Service File ==="
sudo cp spring-app.service /etc/systemd/system/spring-app.service

echo "=== Step 5: Reload Systemd Daemon & Enable Service ==="
sudo systemctl daemon-reload
sudo systemctl enable spring-app.service

echo "=== Setup completed! ==="
echo "Ensure your real Spring Boot app.jar is located at /opt/spring-app/app.jar and start the service with:"
echo "sudo systemctl start spring-app.service"
