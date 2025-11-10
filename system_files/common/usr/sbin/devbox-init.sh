#!/bin/bash

set -eo pipefail

DISTRO=$(. /etc/os-release && echo $ID)

# restore permissions and capabilities for all files on fedora
if [[ "$DISTRO" == "fedora" ]]; then
    rpm -a --restore
fi

# Prompt for username and insist it's not empty
while true; do
    read -p "Please enter your username: " username

    # Check if username is not empty
    if [[ ! -z "$username" ]]; then
        break
    else
        echo "Username cannot be empty. Please try again."
    fi
done

echo "Welcome, $username!"

case "${DISTRO}" in
    ubuntu|debian)
        useradd -m -G sudo,docker -s /usr/bin/zsh "$username"
        ;;
    fedora)
        useradd -m -G wheel,docker -s /usr/bin/zsh "$username"
        ;;
esac


passwd $username

sed -i "s/default=.*/default=$username/" /etc/wsl.conf
echo "$username    ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/usernosudo

echo "user created, now logout with 'exit'"