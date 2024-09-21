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

# Function to install Chromium or Firefox
install_browser() {
  # Get browser name from function argument
  browser_name="$1"

  # Get desired port, username, and password from user
  read -p "Enter desired port: " PORT
  read -p "Enter username for $browser_name: " USERNAME
  read -sp "Enter password for $browser_name: " PASSWORD
  echo

  # Validate port input
  if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "Invalid port. Please enter a positive integer."
    return 1
  fi

  # Docker run command with user-provided values
  docker run -d \
    --name="$browser_name" \
    --security-opt seccomp=unconfined \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Etc/UTC \
    -e CUSTOM_USER="$USERNAME" \
    -e PASSWORD="$PASSWORD" \
    # -e CHROME_CLI=https://www.youtube.com/@IR_TECH/ #optional
    -p "$PORT":3000 \
    -p "$PORT":3001 \
    -v /root/"$browser_name"/config:/config \
    --shm-size="1gb" \
    --restart unless-stopped \
    lscr.io/linuxserver/"$browser_name":latest

  echo "------------------------------------------------------------------------------------------------"
  echo "$browser_name installed successfully."
  IP=$(hostname -I | awk '{print $1}')
  echo "Use browser with http://$IP:$PORT"
}

# Function to uninstall Chromium or Firefox
uninstall_browser() {
  browser_name="$1"
  if docker ps -a | grep -q "$browser_name"; then
    echo "Uninstalling $browser_name..."
    docker stop "$browser_name"
    docker rm "$browser_name"
    echo "$browser_name uninstalled."
  else
    echo "$browser_name is not installed."
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
  1) install_browser chromium ;;
  2) uninstall_browser chromium ;;
  3) install_browser firefox ;;
  4) uninstall_browser firefox ;;
  5) exit ;;
  *) echo "Invalid choice. Please select a valid option." ;;
esac
