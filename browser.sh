#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed."
    read -p "Press Enter to install Docker..."
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

# Function to install Chromium
install_chromium() {
    if docker ps -a | grep -q chromium; then
        echo "Chromium is already installed."
    else
        read -p "Enter username for Chromium : " USERNAME
        read -sp "Enter password for Chromium : " PASSWORD
        echo
        read -p "Enter the first port (left side) for Chromium (e.g., 2000): " PORT1
        read -p "Enter the second port (left side) for Chromium (e.g., 2001): " PORT2
        
        echo "Installing Chromium..."
        docker run -d \
            --name=chromium \
            --security-opt seccomp=unconfined `#optional` \
            -e PUID=1000 \
            -e PGID=1000 \
            -e TZ=Etc/UTC \
            -e CUSTOM_USER=$USERNAME \
            -e PASSWORD=$PASSWORD \
            -e CHROME_CLI=https://www.youtube.com/@IR_TECH/ `#optional` \
            -p $PORT1:3000 \
            -p $PORT2:3001 \
            -v /root/chromium/config:/config \
            --shm-size="1gb" \
            --restart unless-stopped \
            lscr.io/linuxserver/chromium:latest
        
        echo "------------------------------------------------------------------------------------------------"
        echo "Chromium installed successfully."
        IP=$(hostname -I | awk '{print $1}')
        echo " "
        echo "Use browser with http://$IP:$PORT1"
    fi
}

# Function to uninstall Chromium
uninstall_chromium() {
    if docker ps -a | grep -q chromium; then
        echo "Uninstalling Chromium..."
        docker stop chromium
        docker rm chromium
        echo "Chromium uninstalled."
    else
        echo "Chromium is not installed."
    fi
}

# Display the menu
echo "Select an option:"
echo "1) Install Chromium"
echo "2) Uninstall Chromium"
echo "3) Install Firefox"
echo "4) Uninstall Firefox"
echo "5) Exit"
read -p "Please choose : " choice

case $choice in
    1) install_chromium ;;
    2) uninstall_chromium ;;
    3) install_firefox ;;
    4) uninstall_firefox ;;
    5) exit ;;
    *) echo "Invalid choice. Please select a valid option." ;;
esac
