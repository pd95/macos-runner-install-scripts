#!/bin/bash

set -e
set -x

# Environment Variables
source config.sh

export REPO_DIR="$HOME/Downloads/runner-images"
export IMAGE_FOLDER="/Users/${vm_username}/image-generation"

cd "$REPO_DIR/images/macos/templates"

echo "Continuing post-reboot installation..."


# Install additional software
export API_PAT="${github_api_pat}"
export USER_PASSWORD="${vm_password}"
#../scripts/build/configure-windows.sh # closes all open windows
../scripts/build/install-powershell.sh
if [ "${image_os}" -eq macos14 ]; then
  ../scripts/build/install-mono.sh.   # not available on macOS 15
fi
../scripts/build/install-dotnet.sh
../scripts/build/install-python.sh
../scripts/build/install-azcopy.sh
../scripts/build/install-openssl.sh
../scripts/build/install-ruby.sh

source "$HOME/.bash_profile"
../scripts/build/install-rubygems.sh
../scripts/build/install-git.sh
../scripts/build/install-node.sh
../scripts/build/install-common-utils.sh

# Install Xcode
# Make sure the xcode binaries are named Xcode-<version>+<build>.xip and are stored in a path accessible by the runner user
export XCODE_INSTALL_STORAGE_URL="file://${xcode_install_storage_path}"
export XCODE_INSTALL_SAS=""
pwsh -f ../scripts/build/Install-Xcode.ps1

# Reboot again to finalize setup
echo "Rebooting system for final setup..."
sudo shutdown -r +1min
