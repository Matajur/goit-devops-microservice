#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Update package list
echo "Updating package list..."
sudo apt-get update

# 1. Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) \
      signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

# 2. Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    DOCKER_COMPOSE_VERSION="2.37.1"
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully."
else
    echo "Docker Compose is already installed."
fi

# 3. Install Python 3.9 or later
if ! python3 --version | grep -qE "3\.(9|1[0-9])"; then
    echo "Installing Python 3.9..."
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get update
    sudo apt-get install -y python3.9 python3.9-venv python3.9-dev python3-pip
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
    echo "Python 3.9 installed successfully."
else
    echo "Python 3.9 or newer is already installed."
fi

# 4. Install Django via pip
if ! python3 -m django --version &> /dev/null; then
    echo "Installing Django..."
    python3 -m pip install --upgrade pip
    python3 -m pip install django
    echo "Django installed successfully."
else
    echo "Django is already installed."
fi

echo "All development tools are installed and ready to use."
