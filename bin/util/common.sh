function print() {
  echo "-----> $*"
}

function indent() {
  c='s/^/       /'
  case $(uname) in
    Darwin) sed -l "$c";;
    *)      sed -u "$c";;
  esac
}

function error() {
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

function export_env_dir() {
  	local env_dir=$1
  	local whitelist_regex=${2:-''}
  	local blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)$'}
  	if [ -d "$env_dir" ]; then
    		for e in $(ls $env_dir); do
      		echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
      		export "$e=$(cat $env_dir/$e)"
      		:
    		done
  	fi
}
