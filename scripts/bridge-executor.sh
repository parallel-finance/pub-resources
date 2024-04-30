#!/bin/bash

# SCRIPT_PATH=$HOME/.parallel_bridge_install.sh
BASE_KEYSTORE_DIR=$HOME/.parallel_bridge_keystore
ORG=paraspace
IMAGE_NAME=bridge-executor
SERVICE_NAME=bridge-executor

function install_executor() {
    echo "Installing bridge executor service at $BASE_KEYSTORE_DIR"
    if ! command -v docker &>/dev/null; then
        sudo apt upgrade -y
        sudo apt install pkg-config curl build-essential libssl-dev libclang-dev ufw docker-compose-plugin -y

        sudo apt-get install ca-certificates curl gnupg lsb-release

        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        sudo apt-get update

        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    else
        echo "🌀 Docker Installed"
    fi

    # sudo docker run hello-world
    echo "🌀 Pulling the latest image of bridge executor ..."
    docker pull $ORG/$IMAGE_NAME:latest
    echo "🐤 Parallel Bridge Executor installed successfully >#<"
}

function create_keystore() {
    echo "🌀 Creating keystore at $BASE_KEYSTORE_DIR ..."
    docker run --rm -it -v "$BASE_KEYSTORE_DIR:/app/keystore" -e "CI=true" $ORG/$IMAGE_NAME pnpm create-keystore
}

function start_service() {
    echo ":::::::::: 🙌 Ctrl+C 🙌 to exit the service and hang up the container"
    docker run --rm -it --name $SERVICE_NAME -v "$BASE_KEYSTORE_DIR:/app/keystore" --detach-keys="ctrl-c" -e "CI=true" $ORG/$IMAGE_NAME pnpm prod
    echo "🌀 Parallel Bridge Executor service started successfully >#<"
}

function check_service_status() {
    docker logs -f $SERVICE_NAME
}

function check_keystore_status() {
    # list all files in the keystore
    ls -l $BASE_KEYSTORE_DIR/default
    echo "All files in the keystore are listed above"
}

function stop_service() {
    echo "Stopping bridge executor service"
    docker rm -f $SERVICE_NAME
}

function uninstall_executor() {
    echo "Uninstalling bridge executor service"
    docker stop $SERVICE_NAME
    docker rm $SERVICE_NAME
    docker rmi $ORG/$IMAGE_NAME
    echo "Cleaning up keystore at $BASE_KEYSTORE_DIR"
    rm -rf $BASE_KEYSTORE_DIR
    echo "Parallel Bridge Executor uninstalled successfully >#<"
}

function show_menu() {
    echo "================================================================"
    echo "🪭 Parallel Bridge Executor Installer"
    echo "0. ⏩️ Intall parallel bridge executor (required ⛳️)"
    echo "1. 🐤 Create Keystore (required ⛳️)"
    echo "2. 🤖 Start service (required ⛳️)"
    echo "3. 🌀 Check service status"
    echo "4. 🦄 Check keystore status"
    echo "5. 🎯 Stop parallel bridge executor"
    echo "6. 🎨 Uninstall parallel bridge executor"
    echo "7. ✅ Exit the script"
    echo "The basic workflow is 0 -> 1 -> 2"
    read -p "😆 Enter your option: " OPTION
    echo "================================================================"

    case $OPTION in
    0) install_executor ;;
    1) create_keystore ;;
    2) start_service ;;
    3) check_service_status ;;
    4) check_keystore_status ;;
    5) stop_service ;;
    6) uninstall_executor ;;
    7) exit ;;
    *) echo "❌ Invalid option. Please try again(0-7)." ;;
    esac
}

function main_menu() {
    clear
    clear
    if [ "$(id -u)" != "0" ]; then
        echo "please run this script as root user to avoid permission issues."
        echo "try sudo ./ParallelBridgeExecutor.sh"
        exit 1
    fi

    # echo "Script path: $SCRIPT_PATH"
    echo "Keystore path: $BASE_KEYSTORE_DIR"
    echo "HOME path: $HOME"
    while true; do
        show_menu
    done
}

main_menu
