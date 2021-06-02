#!/usr/bin/env bash

# The program requires the use of 'tar' to run, so confirm that it is present.
if ! command -v tar &> /dev/null; then
  echo "tar is required for this application to run"
  exit
fi

# The program requires the use of 'curl' to run, so confirm that is is present.
if ! command -v curl &> /dev/null; then
  echo "curl is required for this application to run"
  exit
fi

# errecho will output the provided message with 'Error:' in red text prefixing
# the message.
errecho() {
  echo "$(tput setaf 1)Error:$(tput sgr0) $1"
}

# infoecho will output the provided message with 'Info:' in blue text prefixing
# the message.
infecho() {
  echo "$(tput setaf 4)Info:$(tput sgr0) $1"
}

# sucecho will output the provided message with 'Success:' in green text
# prefixing the message.
sucecho() {
  echo "$(tput setaf 2)Success:$(tput sgr0) $1"
}

# main is the top level function, confirms that the minimum required number of
# arguments have been provided to the program, ensures the required folders are
# present, and determines which action to run based on the given command.
main() {
  if [[ $# -eq 0 ]]; then
    echo "usage: govm <command>"
    exit
  fi

  mkdir -p "$HOME/.govm/cache"
  mkdir -p "$HOME/go"

  case $1 in
    "install")
      if [[ $# -lt 2 || $# -gt 3 ]]; then
        echo "usage: govm install <version> [workspace]"
        exit
      fi

      install "${@:2}"
    ;;
    "remove")
      if [[ $# -ne 2 ]]; then
        echo "usage: govm remove <workspace>"
        exit
      fi

      remove "$2"
    ;;
    "set")
      if [[ $# -ne 2 ]]; then
        echo "usage: govm set <workspace>"
        exit
      fi

      set "$2"
    ;;
    "list")
      if [[ $# -ne 1 ]]; then
        echo "usage: govm list"
        exit
      fi

      list
    ;;
    *)
      errecho "unrecognized command: $1"
    ;;
  esac
}

# set will set the given version of Go to be the current version that will be
# executed when 'go' is called, and will also be the version of Go that any
# modules are installed under.
set() {
  govm="$HOME/.govm/$1"
  go="$HOME/go/$1"

  if [[ ! -d "$govm" || ! -d "$go" ]]; then
    errecho "install '$1' does not exist or is in a corrupted state"
    exit
  fi

  rm -f "$HOME/.govm/current"
  rm -f "$HOME/go/current"

  ln -s "$govm" "$HOME/.govm/current"
  ln -s "$go" "$HOME/go/current"

  sucecho "set $1 as current"
}

# list will output a table of all the currently installed copies of Go and the
# version of Go they reference. It will also output an indicator showing which
# verison is marked as current.
list() {
  cgo=$(readlink "$HOME/.govm/current")
  for dir in "$HOME/.govm/"*; do
    name="${dir##*/}"

    case $name in 
      "cache"|"current") continue
    esac

    [ "$dir" == "$cgo" ] && cur="$(tput setaf 5)current$(tput sgr0)" || cur=""
    version=$(cat "$dir/VERSION")
    printf "%-15s%-12s%s\n" "$name" "$version" "$cur"
  done
}

# remove will remove an installed version of Go. Because the module directories
# are marked as readonly, the remove command must be run as root.
remove() {
  binsym="$HOME/.govm/current"
  gosym="$HOME/go/current"
  bin="$HOME/.govm/$1"
  go="$HOME/go/$1"

  if [[ ! -d "$bin" || ! -d "$go" ]]; then
    errecho "install '$1' does not exist or is in a corrupted state"
    exit
  fi

  if [[ $EUID -ne 0 ]]; then
    errecho "remove must be run as root"
    exit
  fi

  if [[ $(readlink "$binsym") == "$bin" || $(readlink "$gosym") == "$go" ]]
  then
    rm -rf "$binsym" "$gosym"
  fi

  rm -rf "$bin" "$go"

  sucecho "removed $1"
}

# install will download and unpack the requested version of Go. Unlike other
# actions, because the arguments are parsed differently based on the number
# provided it's pre-condition is a range of values - either 2 oe 3.
#
# It expects sets of arguments in either of the following forms:
#   $ govm install <version>
#   This form will install the the requested verison of Go under the name
#   go<version> (eg: go1.16.4).
#
#   $ govm install <version> <name>
#   This form will install the requested version of Go under the provided name.
#
# install will also set the first version that is installed as the current
# running version to reduce UX friction.
install() {
  name=${2:-"go$1"}
  file="go$1.linux-amd64.tar.gz"
  url="https://golang.org/dl/$file"
  dl="$HOME/.govm/cache/$file"
  out="$HOME/.govm/$name/"
  binsym="$HOME/.govm/current"
  gosym="$HOME/go/current"

  case $name in
    "cache"|"current"|"go")
      errecho "'$name' is a reserved name and cannot be used"
      exit
  esac

  if [[ -d "$out" ]]; then
    errecho "name $name is already in use"
    exit
  fi

  if [[ ! -f "$dl" ]]; then
    infecho "downloading Go binaries from $url"

    if ! curl "$url" --output "$dl" --silent --location --fail; then
      errecho "go version $1 could not be downloaded"
      exit
    fi
  fi

  infecho "unpacking Go binaries archive $dl"

  tar -C "$HOME/.govm" -xzf "$dl"
  mv "$HOME/.govm/go" "$out"
  mkdir "$HOME/go/$name"

  sucecho "installed go$1 as $name"

  if [[ ! -d $binsym && ! -d $gosym ]]; then
    infecho "no version set, setting $name as current"
    set "$name"
  fi
}

# Call the main function.
main "$@"
