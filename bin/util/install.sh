#!/usr/bin/env bash

function get_project_file() {
	local projectfile=$(x=$(dirname $(find $1 -maxdepth 1 -type f | head -1)); while [[ "$x" =~ $1 ]] ; do find "$x" -maxdepth 1 -name *.csproj; x=`dirname "$x"`; done)
	echo $projectfile
}

function get_project_name() {
	local projectname=""
	local projectfile="$(get_project_file $1)"
	if [[ $projectfile ]]; then
		projectname=$(basename ${projectfile%.*})
	fi
	echo $projectname
}

function get_project_version() {
	local projectversion=$(grep -oPm1 "(?<=<TargetFramework>)[^<]+" $1/*.csproj)
	echo $projectversion
}

function get_netcore_version() {
	local netcoreversion="2.2.401" # set dotnet default version
	if [ $1 == "netcoreapp2.1" ]; then
		netcoreversion="2.1.403"
	elif [ $1 == "netcoreapp2.2" ]; then
		netcoreversion="2.2.402"
	elif [ $1 == "netcoreapp3.0" ]; then
		netcoreversion="3.0.100"
	fi
	echo $netcoreversion
}

function install_dotnet() {
  local netcore_version="$1"
  local tar_file_name="dotnet-${netcore_version}.tar.gz"
  
  print "Dotnet sdk: $netcore_version"
  if [ ! -f $CACHE_DIR/$tar_file_name ]; then
    	#https://github.com/dotnet/core/blob/master/release-notes
    	local url=""
	if [ "$netcore_version" == "2.1.4" ]; then
		      url="https://download.microsoft.com/download/1/1/5/115B762D-2B41-4AF3-9A63-92D9680B9409/dotnet-sdk-2.1.4-linux-x64.tar.gz"
	elif [ "$netcore_version" == "2.1.403" ] || [ "$netcore_version" == "2.1.4"* ]; then
          url="https://download.visualstudio.microsoft.com/download/pr/e85de743-f80b-481b-b10e-d2e37f05a7ce/0bf3ff93417e19ad8d6b2d3ded84d664/dotnet-sdk-2.1.403-linux-x64.tar.gz"
    	elif [ "$netcore_version" == "2.2.104" ] || [ "$netcore_version" == "2.2"* ]; then
          url="https://download.visualstudio.microsoft.com/download/pr/69937b49-a877-4ced-81e6-286620b390ab/8ab938cf6f5e83b2221630354160ef21/dotnet-sdk-2.2.104-linux-x64.tar.gz"
    	elif [ "$netcore_version" == "2.2.103" ] || [ "$netcore_version" == "2.2"* ]; then
          url="https://download.visualstudio.microsoft.com/download/pr/296e116b-30d7-4e1c-8238-ec8c7c4c7b79/43d6cd35d95e38675d472c56a24c3bd0/dotnet-sdk-2.2.103-linux-x64.tar.gz"
    	elif [ "$netcore_version" == "2.2.401" ] || [ "$netcore_version" == "2.2"* ]; then
          url="https://download.visualstudio.microsoft.com/download/pr/228832ea-805f-45ab-8c88-fa36165701b9/16ce29a06031eeb09058dee94d6f5330/dotnet-sdk-2.2.401-linux-x64.tar.gz"
	elif [ "$netcore_version" == "2.2.402" ] || [ "$netcore_version" == "2.2"* ]; then
		      url="https://download.visualstudio.microsoft.com/download/pr/46411df1-f625-45c8-b5e7-08ab736d3daa/0fbc446088b471b0a483f42eb3cbf7a2/dotnet-sdk-2.2.402-linux-x64.tar.gz"
	elif [ "$netcore_version" == "3.0.100" ] || [ "$netcore_version" == "3.0"* ]; then
		      url="https://download.visualstudio.microsoft.com/download/pr/886b4a4c-30af-454b-8bec-81c72b7b4e1f/d1a0c8de9abb36d8535363ede4a15de6/dotnet-sdk-3.0.100-linux-x64.tar.gz"
    	fi
      	print "Download url: $url"
      	curl -sSL -o $CACHE_DIR/$tar_file_name $url
  else
    echo "$tar_file_name from cache folder"
  fi

  mkdir -p ${BUILD_DIR}/.heroku/dotnet && tar zxf $CACHE_DIR/$tar_file_name -C ${BUILD_DIR}/.heroku/dotnet
  ln -s ${BUILD_DIR}/.heroku/dotnet /app
}

function apt_install(){
  print "Install package"

  local apt_cache_dir="$CACHE_DIR/apt/cache"
  local apt_state_dir="$CACHE_DIR/apt/state"
  
  mkdir -p "$apt_cache_dir/archives/partial"
  mkdir -p "$apt_state_dir/lists/partial"
  
  local apt_options="-o debug::nolocking=true -o dir::cache=$apt_cache_dir -o dir::state=$apt_state_dir"
  
  print "Cleaning apt caches"
  apt-get $apt_options clean | indent
  
  print "Updating apt caches"
  apt-get  --allow-unauthenticated $apt_options update | indent

  mkdir -p "$BUILD_DIR/.apt"
  
  for package in "$@"; do
    if [[ $package == *deb ]]; then
      local package_name=$(basename $package .deb)
      local package_file=$apt_cache_dir/archives/$package_name.deb
      print "Fetching $package"
      curl -s -L -z $package_file -o $package_file $package 2>&1 | indent
    else
      print "Fetching .debs for $package"
      apt-get $apt_options -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -d install --reinstall $package | indent
    fi
    
    print "Installing $package"
    local deb="$(ls $apt_cache_dir/archives | grep $package)"
    dpkg -x $apt_cache_dir/archives/$deb "$BUILD_DIR/.apt/"
    dpkg -b $deb "$BUILD_DIR/.apt/"
    #ln -s $BUILD_DIR/.apt/$package-@PACKAGE_VERSION@ ${DESTDIR}/usr/local/bin/s
  done
  
  export PATH="$PATH:$BUILD_DIR/.apt/usr/bin"
  export LD_LIBRARY_PATH="$BUILD_DIR/.apt/usr/lib/x86_64-linux-gnu:$BUILD_DIR/.apt/usr/lib/i386-linux-gnu:$BUILD_DIR/.apt/usr/lib:${LD_LIBRARY_PATH-}"
  export LIBRARY_PATH="$BUILD_DIR/.apt/usr/lib/x86_64-linux-gnu:$BUILD_DIR/.apt/usr/lib/i386-linux-gnu:$BUILD_DIR/.apt/usr/lib:${LIBRARY_PATH-}"
  export INCLUDE_PATH="$BUILD_DIR/.apt/usr/include:${INCLUDE_PATH-}"
  export CPATH="${INCLUDE_PATH-}"
  export CPPPATH="${INCLUDE_PATH-}"
  export PKG_CONFIG_PATH="$BUILD_DIR/.apt/usr/lib/x86_64-linux-gnu/pkgconfig:$BUILD_DIR/.apt/usr/lib/i386-linux-gnu/pkgconfig:$BUILD_DIR/.apt/usr/lib/pkgconfig:${PKG_CONFIG_PATH-}"
  print "APT packages Installled"
}
