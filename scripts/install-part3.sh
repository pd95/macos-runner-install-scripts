#!/bin/bash

set -e
set -x

# Environment Variables
source config.sh

export REPO_DIR="$HOME/Downloads/runner-images"
export IMAGE_FOLDER="/Users/${vm_username}/image-generation"

cd "$REPO_DIR/images/macos/templates"

# Final setup after reboot
echo "Finalizing setup post-reboot..."

# Install additional tools
export API_PAT="${github_api_pat}"
../scripts/build/install-actions-cache.sh
../scripts/build/install-runner-package.sh
../scripts/build/install-llvm.sh
../scripts/build/install-openjdk.sh
../scripts/build/install-aws-tools.sh
../scripts/build/install-rust.sh
../scripts/build/install-gcc.sh
../scripts/build/install-cocoapods.sh
../scripts/build/install-android-sdk.sh
../scripts/build/install-safari.sh
../scripts/build/install-chrome.sh
../scripts/build/install-bicep.sh
../scripts/build/install-codeql-bundle.sh

# Configure toolset
pwsh -f ../scripts/build/Install-Toolset.ps1
pwsh -f ../scripts/build/Configure-Toolset.ps1

# Configure Xcode Simulators
pwsh -f ../scripts/build/Configure-Xcode-Simulators.ps1

# Run software report and tests
source "$HOME/.bash_profile"
export IMAGE_VERSION="${build_id}"
pwsh -File "$IMAGE_FOLDER/software-report/Generate-SoftwareReport.ps1" -OutputDirectory "$IMAGE_FOLDER/output/software-report" -ImageName "$BUILD_ID"
pwsh -File "$IMAGE_FOLDER/tests/RunAll-Tests.ps1"

# Final system configuration
../scripts/build/configure-hostname.sh
../scripts/build/configure-system.sh

echo "Installation complete"
sudo shutdown -r +1min
