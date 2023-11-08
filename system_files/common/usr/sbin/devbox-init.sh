#!/bin/bash

set -eo pipefail

# (on fedora) restore permissions and capabilities for all files
rpm -a --restore || true

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

if [  -n "$(grep NAME /etc/os-release | grep Ubuntu)" ]; then
    useradd -m -G sudo,docker -s /usr/bin/zsh $username
else
    useradd -m -G wheel,docker -s /usr/bin/zsh $username
fi


passwd $username

sed -i "s/default=.*/default=$username/" /etc/wsl.conf
echo "$username    ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/usernosudo

echo "user created, now logout with 'exit'"