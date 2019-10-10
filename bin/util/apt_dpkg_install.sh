#!/usr/bin/env bash

function apt_install(){
	echo "Install package"

	local apt_cache_dir="$CACHE_DIR/apt/cache"
	local apt_state_dir="$CACHE_DIR/apt/state"

	mkdir -p "$apt_cache_dir/archives/partial"
	mkdir -p "$apt_state_dir/lists/partial"

	local apt_options="-o debug::nolocking=true -o dir::cache=$apt_cache_dir -o dir::state=$apt_state_dir"

	print "Cleaning apt caches"
	apt-get $apt_options clean | indent

	print "Updating apt caches"
	apt-get  --allow-unauthenticated $apt_options update | indent

	for package in "$@"; do
		[ -z "$($LDCONFIG_COMMAND 2>/dev/null | grep libunwind)" ]
		if [[ $package == *deb ]]; then
			local package_name=$(basename $package .deb)
			local package_file=$apt_cache_dir/archives/$package_name.deb
			print "Fetching $package"
			curl -s -L -z $package_file -o $package_file $package 2>&1 | indent
		else
			print "Fetching .debs for $package"
			apt-get $apt_options -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -d install --reinstall $package | indent
		fi
	done

	mkdir -p "$BUILD_DIR/.apt"

	for DEB in $(ls -1 $apt_cache_dir/archives/*.deb); do
		print "Installing $(basename $DEB)"
		dpkg -x $DEB "$BUILD_DIR/.apt/"
	done

	export PATH="$PATH:$BUILD_DIR/.apt/usr/bin"
	export LD_LIBRARY_PATH="$BUILD_DIR/.apt/usr/lib/x86_64-linux-gnu:$BUILD_DIR/.apt/usr/lib/i386-linux-gnu:$BUILD_DIR/.apt/usr/lib:${LD_LIBRARY_PATH-}"
	export LIBRARY_PATH="$BUILD_DIR/.apt/usr/lib/x86_64-linux-gnu:$BUILD_DIR/.apt/usr/lib/i386-linux-gnu:$BUILD_DIR/.apt/usr/lib:${LIBRARY_PATH-}"
	export INCLUDE_PATH="$BUILD_DIR/.apt/usr/include:${INCLUDE_PATH-}"
	export CPATH="${INCLUDE_PATH-}"
	export CPPPATH="${INCLUDE_PATH-}"
	echo "APT packages Installled"
}

is_dpkg_installed() {
    if [ "$(uname)" = "Linux" ]; then
        if [ ! -x "$(command -v ldconfig)" ]; then
            echo "ldconfig is not in PATH, trying /sbin/ldconfig."
            LDCONFIG_COMMAND="/sbin/ldconfig"
        else
            LDCONFIG_COMMAND="ldconfig"
        fi

        local librarypath=${LD_LIBRARY_PATH:-}
        LDCONFIG_COMMAND="$LDCONFIG_COMMAND -NXv ${librarypath//:/ }"
	if [[ -z "$($LDCONFIG_COMMAND 2>/dev/null | grep $package)" ]]; then
		echo 0
	else
		echo 1
	fi
    fi

    return 0
}
