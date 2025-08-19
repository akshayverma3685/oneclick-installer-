#!/bin/bash

# Colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
cyan='\033[0;36m'
reset='\033[0m'

# Detect package manager
if command -v pkg >/dev/null 2>&1; then
    PKG="pkg"
    IS_TERMUX=true
elif command -v apt >/dev/null 2>&1; then
    PKG="apt"
    IS_TERMUX=false
else
    echo -e "${red}No supported package manager found! (apt/pkg required)${reset}"
    exit 1
fi

# Package list
declare -A packages=(
    [1]="python"
    [2]="python3"
    [3]="openjdk-17"
    [4]="php"
    [5]="curl"
    [6]="git"
    [7]="wget"
    [8]="nodejs"
    [9]="golang"
    [10]="ruby"
)

# Show menu
show_menu() {
    echo -e "\n${cyan}========= OneClick Installer =========${reset}"
    echo "Choose option:"
    for key in "${!packages[@]}"; do
        echo "  $key) Install ${packages[$key]}"
    done
    echo "  a) Install ALL packages"
    echo "  u) Uninstall packages"
    echo "  up) Update & Upgrade system"
    if $IS_TERMUX; then
        echo "  s) Setup Termux storage"
    fi
    echo "  q) Quit"
    echo -e "${cyan}======================================${reset}\n"
}

# Install package
install_package() {
    pkg_name=$1
    echo -e "${yellow}Installing $pkg_name...${reset}"
    $PKG install -y $pkg_name
    if [ $? -eq 0 ]; then
        echo -e "${green}$pkg_name installed successfully.${reset}"
    else
        echo -e "${red}Failed to install $pkg_name.${reset}"
    fi
}

# Uninstall package
uninstall_package() {
    pkg_name=$1
    echo -e "${yellow}Uninstalling $pkg_name...${reset}"
    $PKG remove -y $pkg_name
    if [ $? -eq 0 ]; then
        echo -e "${green}$pkg_name uninstalled successfully.${reset}"
    else
        echo -e "${red}Failed to uninstall $pkg_name.${reset}"
    fi
}

# Update system
update_system() {
    echo -e "${yellow}Updating & Upgrading system...${reset}"
    $PKG update -y && $PKG upgrade -y
    echo -e "${green}System update complete.${reset}"
}

# Setup storage (Termux only)
setup_storage() {
    if $IS_TERMUX; then
        echo -e "${yellow}Setting up Termux storage...${reset}"
        termux-setup-storage
        echo -e "${green}Storage setup complete.${reset}"
    else
        echo -e "${red}This option is only for Termux!${reset}"
    fi
}

# Main loop
while true; do
    show_menu
    read -p "Enter choice (single/multiple like 1 2 3 / a / u / up / s / q): " choice

    case $choice in
        q)
            echo -e "${red}Exiting OneClick Installer...${reset}"
            exit 0
            ;;
        a)
            for key in "${!packages[@]}"; do
                install_package "${packages[$key]}"
            done
            ;;
        u)
            echo "Available packages for uninstall:"
            for key in "${!packages[@]}"; do
                echo "  $key) ${packages[$key]}"
            done
            read -p "Enter package numbers to uninstall: " uninstall_choice
            for num in $uninstall_choice; do
                if [[ -n "${packages[$num]}" ]]; then
                    uninstall_package "${packages[$num]}"
                else
                    echo -e "${red}Invalid option: $num${reset}"
                fi
            done
            ;;
        up)
            update_system
            ;;
        s)
            setup_storage
            ;;
        *)
            for num in $choice; do
                if [[ -n "${packages[$num]}" ]]; then
                    install_package "${packages[$num]}"
                else
                    echo -e "${red}Invalid option: $num${reset}"
                fi
            done
            ;;
    esac
done
