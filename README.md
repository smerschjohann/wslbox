# Devbox Images

This repository contains opinionated WSL distributions. It has a shared `/home` mechanism and allows to reinstall WSL distributions without loosing data. You can also experiment with different distributions.

To do this, it uses the fact, that all WSL distributions run on the same VM. Microsoft allows to share directories in the `/mnt/wsl` directory. We use this fact in the following way:

1. Create a wsl-data distribution, that is not actively used, but holds shared data. This distribution needs at the bash and mount commands. I base this from a `busybox` container.
2. From the wsl-data distribution, bind mount a local /data directory to the /mnt/wsl/data directory.
3. On each boot of our main distribution(s), check if the data is already mounted. If not, start the wsl-data distribution and mount it accordingly.
4. Bind mount the /mnt/wsl/data/home directory to /home.

## Installation

Download a current build from the release page and extract them (for example with 7-Zip).

Run the following commands:

1. Install the `wsl-data` shared distribution

```powershell
wsl.exe --import wsl-data "$HOME\wsl\wsl-data" "./wsl-data.tar"
```

2. Install the main distribution

```powershell
# import the distribution (customize the path to your liking)
wsl.exe --import devbox "$HOME\wsl\devbox" ./devbox-fedora-wsl.tar

# start the distribution, it will request you to create a user
wsl.exe -d devbox

# exit the WSL distribution again after completing the setup.

# terminate the WSL once
wsl.exe -t devbox

# now you can start it, the installation is complete
wsl.exe -d devbox
```