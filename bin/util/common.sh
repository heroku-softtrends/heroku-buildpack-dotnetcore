print() {
	echo "-----> $*"
}

indent() {
	c='s/^/       /'
	case $(uname) in
	Darwin) sed -l "$c";;
	*)      sed -u "$c";;
	esac
}

get_os() {
	uname | tr '[:upper:]' '[:lower:]'
}

get_cpu() {
	if [[ "$(uname -p)" = "i686" ]]; then
	echo "x86"
	else
	echo "x64"
	fi
}

get_platform() {
	os=$(get_os)
	cpu=$(get_cpu)
	echo "$os-$cpu"
}

get_linux_platform_name() {
	if [ -e /etc/os-release ]; then
	    . /etc/os-release
	    echo "$ID.$VERSION_ID"
	    return 0
	elif [ -e /etc/redhat-release ]; then
	    local redhatRelease=$(</etc/redhat-release)
	    if [[ $redhatRelease == "CentOS release 6."* || $redhatRelease == "Red Hat Enterprise Linux "*" release 6."* ]]; then
		echo "rhel.6"
		return 0
	    fi
	fi

	print "Linux specific platform name and version could not be detected: UName = $uname"
	return 1
}

get_linux_platform_version() {
	if [ -e /etc/os-release ]; then
	    . /etc/os-release
	    echo "$VERSION_ID"
	    return 0
	fi

	print "Linux specific platform version could not be detected: UName = $uname"
	return 1
}

error() {
	local c="2,999 s/^/ !     /"
	# send all of our output to stderr
	exec 1>&2

	echo -e "\033[1;31m" # bold; red
	echo -n " !     ERROR: "
	# this will be fed from stdin
	case $(uname) in
		Darwin) sed -l "$c";; # mac/bsd sed: -l buffers on line boundaries
		*)      sed -u "$c";; # unix/gnu sed: -u unbuffered (arbitrary) chunks of data
	esac
	echo -e "\033[0m" # reset style
	exit 1
}

export_env_dir() {
  local env_dir=$1
  if [ -d "$env_dir" ]; then
    local whitelist_regex=${2:-''}
    local blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH|LANG|BUILD_DIR)$'}
    # shellcheck disable=SC2164
    pushd "$env_dir" >/dev/null
    for e in *; do
      [ -e "$e" ] || continue
      echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
      export "$e=$(cat "$e")"
      :
    done
    # shellcheck disable=SC2164
    popd >/dev/null
  fi
}
