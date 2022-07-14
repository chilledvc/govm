#!/usr/bin/env bash

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

# Ensure that the setup script is being run as root.
if [[ $EUID -ne 0 ]]; then
  errecho "setup must be run as root"
  exit
fi

# Copy the govm script into /usr/local/bin
infecho "copying govm.sh into /usr/local/bin/ as govm"
cp ./govm.sh /usr/local/bin/govm

# Get the home directory of the user that called the script
home=$(eval echo "~$SUDO_USER")

# Append necessary lines to .cvcinit to update PATH and GOPATH
infecho "modifying .cvcinit to update PATH and GOPATH"
touch "$home/.cvcinit"
echo 'export GOPATH="$HOME/go/current"' >> "$home/.cvcinit"
echo 'export PATH="$HOME/.govm/current/bin:$PATH"' >> "$home/.cvcinit"
echo 'export PATH="$GOPATH/bin:$PATH"' >> "$home/.cvcinit"

# Notify the user that setup has completed
sucecho "setup completed"
