#!/bin/bash

set -e
set -x

# Environment Variables
source config.sh

export REPO_DIR="$HOME/Downloads/runner-images"
export IMAGE_FOLDER="/Users/${vm_username}/image-generation"

if [ ! -d "$REPO_DIR" ]; then
    cd "$HOME/Downloads"
    cd /tmp
    curl -OL https://github.com/actions/runner-images/archive/refs/heads/main.zip
    unzip main.zip
    rm main.zip
    mv runner-images-main "$REPO_DIR"
fi

# Change to the correct directory
cd "$REPO_DIR/images/macos/templates"


# Create necessary directories
mkdir -p "$IMAGE_FOLDER"
mkdir -p "$HOME/bootstrap"
mkdir -p "$HOME/utils"

# Copy files
cp -r "../scripts/tests" "$IMAGE_FOLDER/"
cp -r "../scripts/docs-gen" "$IMAGE_FOLDER/"
cp -r "../scripts/helpers" "$IMAGE_FOLDER/"
cp -r "../../../helpers/software-report-base" "$IMAGE_FOLDER/docs-gen/"
cp "../assets/add-certificate.swift" "$IMAGE_FOLDER/add-certificate.swift"
cp "../assets/bashrc" "$HOME/.bashrc"
cp "../assets/bashprofile" "$HOME/.bash_profile"
cp -r "../assets/bootstrap-provisioner/" "$HOME/bootstrap"
cp "../toolsets/toolset-${os_version}.json" "$IMAGE_FOLDER/toolset.json"

# Move and setup utilities
mv "$IMAGE_FOLDER/docs-gen" "$IMAGE_FOLDER/software-report"
mv "$IMAGE_FOLDER/helpers/invoke-tests.sh" "$HOME/utils"
mv "$IMAGE_FOLDER/helpers/utils.sh" "$HOME/utils"

# Execute scripts with sudo where necessary
chmod +x ../scripts/build/*.sh

source "$HOME/.bash_profile"
../scripts/build/install-xcode-clt.sh
../scripts/build/install-homebrew.sh
../scripts/build/install-rosetta.sh


# Update macOS configuration
export USERNAME="${vm_username}"
export PASSWORD="${vm_password}"
source "$HOME/.bash_profile"
sudo ../scripts/build/configure-tccdb-macos.sh
sudo ../scripts/build/configure-autologin.sh
sudo ../scripts/build/configure-auto-updates.sh
sudo ../scripts/build/configure-ntpconf.sh
sudo ../scripts/build/configure-shell.sh


# Do some more configuration
source "$HOME/.bash_profile"

export IMAGE_VERSION="${build_id}"
export IMAGE_OS="${image_os}"
../scripts/build/configure-preimagedata.sh
../scripts/build/configure-ssh.sh

# avoid issues with chmod sudoers.d by adding a dummy file and removing it afterwards 
sudo touch /etc/sudoers.d/dummy
../scripts/build/configure-machine.sh
sudo rm /etc/sudoers.d/dummy
echo "Rebooting system..."
sudo shutdown -r +1min
