#!/usr/bin/env bash

function apt_install(){
	local apt_cache_dir="$CACHE_DIR/apt/cache"
	local apt_state_dir="$CACHE_DIR/apt/state"

	mkdir -p "$apt_cache_dir/archives/partial"
	mkdir -p "$apt_state_dir/lists/partial"

	local apt_options="-o debug::nolocking=true -o dir::cache=$apt_cache_dir -o dir::state=$apt_state_dir"

	print "Cleaning apt caches"
	apt-get $apt_options clean | indent

	print "Updating apt caches"
	apt-get  --allow-unauthenticated $apt_options update | indent

	if [ ! -d "$BUILD_DIR/.apt" ]; then
		mkdir -p "$BUILD_DIR/.apt"
	fi

	declare -i is_pakage_downloaded=0
	
	for package in "$@"; do
		local has_installed_package=""
		
		if [[ $package == "openssl"* ]]; then
			has_installed_package="openssl"
		elif [[ $package == "libicu"* ]]; then
			has_installed_package="libicu"
		elif [[ $package == "xmlstar"* ]]; then
			has_installed_package="xmlstarlet"
		else
			has_installed_package=$package
		fi
		
		local has_installed=$(is_dpkg_installed $has_installed_package)
		#if [[ $has_installed == *"Unable to locate $has_installed_package"* ]]; then
			if [[ $package == *deb ]]; then
				local package_name=$(basename $package .deb)
				local package_file=$apt_cache_dir/archives/$package_name.deb
				print "Fetching $package"
				curl -s -L -z $package_file -o $package_file $package 2>&1 | indent
			else
				print "Fetching .debs for $package"
				apt-get $apt_options -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -d install --reinstall $package | indent
			fi
			is_pakage_downloaded=is_pakage_downloaded+1
		#elif [[ $has_installed == *"$has_installed_package has installed"* ]]; then
		#	print "$package has installed."
		#else
		#	print "Unable to locate $has_installed_package"
		#fi
	done

	if [[ -d $apt_cache_dir/archives ]] && [[ $(find $apt_cache_dir/archives -maxdepth 1 -name '*.deb' | wc -l) -ne 0 ]]; then
		for DEB in $(ls -1 $apt_cache_dir/archives/*.deb); do
			#dpkg --info $DEB
			print "Installing $(basename $DEB)"
			dpkg -x $DEB "$BUILD_DIR/.apt/"
		done
	fi
	
	export PATH="$PATH:$BUILD_DIR/.apt/usr/bin"
	export LD_LIBRARY_PATH="$BUILD_DIR/.apt/usr/lib/x86_64-linux-gnu:$BUILD_DIR/.apt/usr/lib/i386-linux-gnu:$BUILD_DIR/.apt/usr/lib:${LD_LIBRARY_PATH-}"
	export LIBRARY_PATH="$BUILD_DIR/.apt/usr/lib/x86_64-linux-gnu:$BUILD_DIR/.apt/usr/lib/i386-linux-gnu:$BUILD_DIR/.apt/usr/lib:${LIBRARY_PATH-}"
	export INCLUDE_PATH="$BUILD_DIR/.apt/usr/include:${INCLUDE_PATH-}"
	export CPATH="${INCLUDE_PATH-}"
	export CPPPATH="${INCLUDE_PATH-}"
	echo "Environment variables has exported"
}

is_dpkg_installed() {

	if [ "$(uname)" = "Linux" ]; then
		if [ ! -x "$(command -v ldconfig)" ]; then
		    print "ldconfig is not in PATH, trying /sbin/ldconfig."
		    LDCONFIG_COMMAND="/sbin/ldconfig"
		else
		    LDCONFIG_COMMAND="ldconfig"
		fi

		local librarypath="$BUILD_DIR/.apt/usr/bin:${LD_LIBRARY_PATH-}"
		#librarypath=$(string_replace "$librarypath" "$BUILD_DIR" "$HOME")
		#echo "$LDCONFIG_COMMAND -NXv ${librarypath//:/ } 2>/dev/null  | grep $1"
		if [[ -z "$($LDCONFIG_COMMAND -NXv ${librarypath//:/ } 2>/dev/null | grep $1)" ]]; then
			echo "Unable to locate $1"
		else
			echo "$1 has installed"
		fi
	fi
	
    	return 0
}
