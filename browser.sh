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

# Function to install multiple Chromium containers
install_multiple_chromium() {
    read -p "Enter username for Chromium : " USERNAME
    read -sp "Enter password for Chromium : " PASSWORD
    echo

    # Starting port
    START_PORT=4000
    PORT_INCREMENT=1000
    CONTAINER_COUNT=20

    for ((i = 0; i < CONTAINER_COUNT; i++)); do
        CURRENT_PORT_LEFT1=$((START_PORT + i * PORT_INCREMENT))
        CURRENT_PORT_LEFT2=$((CURRENT_PORT_LEFT1 + 1))  # پورت دوم با افزایش ۱
        CURRENT_PORT_RIGHT1=3000
        CURRENT_PORT_RIGHT2=3001
        CONTAINER_NAME="chromium_$CURRENT_PORT_LEFT1"

        if docker ps -a | grep -q $CONTAINER_NAME; then
            echo "Container $CONTAINER_NAME already exists. Skipping..."
        else
            echo "Installing Chromium on ports $CURRENT_PORT_LEFT1:$CURRENT_PORT_RIGHT1 and $CURRENT_PORT_LEFT2:$CURRENT_PORT_RIGHT2..."
            docker run -d \
                --name=$CONTAINER_NAME \
                --security-opt seccomp=unconfined `#optional` \
                -e PUID=1000 \
                -e PGID=1000 \
                -e TZ=Etc/UTC \
                -e CUSTOM_USER=$USERNAME \
                -e PASSWORD=$PASSWORD \
                -e CHROME_CLI=https://www.youtube.com/@IR_TECH/ `#optional` \
                -p $CURRENT_PORT_LEFT1:$CURRENT_PORT_RIGHT1 \
                -p $CURRENT_PORT_LEFT2:$CURRENT_PORT_RIGHT2 \
                -v /root/chromium/config_$CURRENT_PORT_LEFT1:/config \
                --shm-size="1gb" \
                --restart unless-stopped \
                lscr.io/linuxserver/chromium:latest

            echo "Chromium container $CONTAINER_NAME installed successfully on ports $CURRENT_PORT_LEFT1:$CURRENT_PORT_RIGHT1 and $CURRENT_PORT_LEFT2:$CURRENT_PORT_RIGHT2."
            IP=$(hostname -I | awk '{print $1}')
            echo "Use browser with http://$IP:$CURRENT_PORT_LEFT1"
            echo "------------------------------------------------------------------------------------------------"
        fi
    done
}

# Function to uninstall all Chromium containers
uninstall_all_chromium() {
    CONTAINER_COUNT=20
    START_PORT=4000
    PORT_INCREMENT=1000

    for ((i = 0; i < CONTAINER_COUNT; i++)); do
        CURRENT_PORT_LEFT1=$((START_PORT + i * PORT_INCREMENT))
        CONTAINER_NAME="chromium_$CURRENT_PORT_LEFT1"

        if docker ps -a | grep -q $CONTAINER_NAME; then
            echo "Uninstalling Chromium container $CONTAINER_NAME..."
            docker stop $CONTAINER_NAME
            docker rm $CONTAINER_NAME
            echo "Chromium container $CONTAINER_NAME uninstalled."
        else
            echo "Chromium container $CONTAINER_NAME does not exist."
        fi
    done
}

# Display the menu
echo "Select an option:"
echo "1) Install Multiple Chromium Containers"
echo "2) Uninstall All Chromium Containers"
echo "3) Exit"
read -p "Please choose : " choice

case $choice in
    1) install_multiple_chromium ;;
    2) uninstall_all_chromium ;;
    3) exit ;;
    *) echo "Invalid choice. Please select a valid option." ;;
esac
