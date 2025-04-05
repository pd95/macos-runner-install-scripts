export os_version=`sw_vers -productVersion | awk -F '.' '{print $1}'`
export image_os=macos${os_version}
export build_id="${image_os}_`date "+%Y%m%d.%H%M"`"
export vm_username=runner
export vm_password=password
export github_api_pat=github_pat_12345RANDOMTEXTNOISE
export xcode_install_storage_path="/Users/runner/Desktop/VirtualBuddyShared/Xcode-Binaries/"
