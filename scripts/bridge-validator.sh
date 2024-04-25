#!/bin/bash

# SCRIPT_PATH=$HOME/.parallel_bridge_install.sh
BASE_KEYSTORE_DIR=$HOME/.parallel_bridge_keystore
ORG=paraspace
IMAGE_NAME=bridge-validator
SERVICE_NAME=bridge-dvn-verifier

function install_dvn_verifier() {
    echo "Installing bridge dvn verifier service at $BASE_KEYSTORE_DIR"
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
    echo "🌀 Pulling the latest image of bridge dvn verifier ..."
    docker pull $ORG/$IMAGE_NAME:latest
    echo "🐤 Parallel Bridge DVN Verifier installed successfully >#<"
}

function create_keystore() {
    echo "🌀 Creating keystore at $BASE_KEYSTORE_DIR ..."
    docker run --rm -it -v "$BASE_KEYSTORE_DIR:/app/keystore" -e "CI=true" $ORG/$IMAGE_NAME pnpm create-keystore
}

function start_oracle() {
    docker run --rm -it --name $SERVICE_NAME -v "$BASE_KEYSTORE_DIR:/app/keystore" --detach-keys="ctrl-c" -e "CI=true" $ORG/$IMAGE_NAME pnpm prod-oracle
}

function start_verifier() {
    docker run --rm -it --name $SERVICE_NAME -v "$BASE_KEYSTORE_DIR:/app/keystore" --detach-keys="ctrl-c" -e "CI=true" $ORG/$IMAGE_NAME pnpm prod-verifier
}

function start_oracle_and_verifier() {
    docker run --rm -it --name $SERVICE_NAME -v "$BASE_KEYSTORE_DIR:/app/keystore" --detach-keys="ctrl-c" -e "CI=true" $ORG/$IMAGE_NAME pnpm prod
}

function start_service() {
    echo "Starting bridge dvn verifier service"
    echo "================================================================"
    echo "Please enter the mode of the service (default: 0)"
    echo "0. ⏩️ oracle mode (default ⛳️)"
    echo "1. 🐤 vefivier mode (advanced)"
    echo "2. 🤖 oracle & verifier mode (advanced)"
    read -p "😆 Enter your option: " MODE
    echo "================================================================"

    case $MODE in
    0) start_oracle ;;
    1) start_verifier ;;
    2) start_oracle_and_verifier ;;
    7) exit ;;
    *) echo "❌ Invalid option. Please try again(0-2)." ;;
    esac
    echo ":::::::::: 🙌 Ctrl+C 🙌 to exit the service and hang up the container"

    docker run --rm -it --name $SERVICE_NAME -v "$BASE_KEYSTORE_DIR:/app/keystore" --detach-keys="ctrl-c" -e "CI=true" $ORG/$IMAGE_NAME pnpm prod
    echo "🌀 Parallel Bridge DVN Verifier service started successfully >#<"
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
    echo "Stopping bridge dvn verifier service"
    docker rm -f $SERVICE_NAME
}

function uninstall_dvn_verifier() {
    echo "Uninstalling bridge dvn verifier service"
    docker stop $SERVICE_NAME
    docker rm $SERVICE_NAME
    docker rmi $ORG/$IMAGE_NAME
    echo "Cleaning up keystore at $BASE_KEYSTORE_DIR"
    rm -rf $BASE_KEYSTORE_DIR
    echo "Parallel Bridge DVN Verifier uninstalled successfully >#<"
}

function show_menu() {
    echo "================================================================"
    echo "🪭 Parallel Bridge DVN Verifier Installer"
    echo "0. ⏩️ Intall parallel bridge dvn verifier (required ⛳️)"
    echo "1. 🐤 Create Keystore (required ⛳️)"
    echo "2. 🤖 Start service (required ⛳️)"
    echo "3. 🌀 Check service status"
    echo "4. 🦄 Check keystore status"
    echo "5. 🎯 Stop parallel bridge dvn verifier"
    echo "6. 🎨 Uninstall parallel bridge dvn verifier"
    echo "7. ✅ Exit the script"
    echo "The basic workflow is 0 -> 1 -> 2"
    read -p "😆 Enter your option: " OPTION
    echo "================================================================"

    case $OPTION in
    0) install_dvn_verifier ;;
    1) create_keystore ;;
    2) start_service ;;
    3) check_service_status ;;
    4) check_keystore_status ;;
    5) stop_service ;;
    6) uninstall_dvn_verifier ;;
    7) exit ;;
    *) echo "❌ Invalid option. Please try again(0-7)." ;;
    esac
}

function main_menu() {
    clear
    # echo "Script path: $SCRIPT_PATH"
    echo "Keystore path: $BASE_KEYSTORE_DIR"
    echo "HOME path: $HOME"
    while true; do
        show_menu
    done
}

main_menu
