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

get_project_file() {
	local projectfile=$(x=$(dirname $(find $1 -maxdepth 1 -type f | head -1)); while [[ "$x" =~ $1 ]] ; do find "$x" -maxdepth 1 -name *.csproj; x=`dirname "$x"`; done)
	echo $projectfile
}

get_project_name() {
	local projectname=""
	local projectfile="$(get_project_file $1)"
	if [[ $projectfile ]]; then
		projectname=$(basename ${projectfile%.*})
	fi
	echo $projectname
}

get_project_version() {
	local projectversion=$(grep -oPm1 "(?<=<TargetFramework>)[^<]+" $1/*.csproj)
	echo $projectversion
}

function export_env_dir() {
  	local env_dir=$1
  	local whitelist_regex=${2:-''}
  	local blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)$'}
	print "env dir: $env_dir"
  	if [ -d "$env_dir" ]; then
    		for e in $(ls $env_dir); do
      		echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
      		export "$e=$(cat $env_dir/$e)"
		print "env var: $e"
      		:
    		done
  	fi
}
