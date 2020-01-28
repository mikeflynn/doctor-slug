#!/usr/bin/env bash

DOFIX=0

cat << "EOF"

 ▄▄▄▄▄▄▄▄▄▄   ▄▄▄▄▄▄▄▄▄▄▄          ▄▄▄▄▄▄▄▄▄▄▄  ▄            ▄         ▄  ▄▄▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌        ▐░░░░░░░░░░░▌▐░▌          ▐░▌       ▐░▌▐░░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌        ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌          ▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀▀▀
▐░▌       ▐░▌▐░▌       ▐░▌        ▐░▌          ▐░▌          ▐░▌       ▐░▌▐░▌
▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌        ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌          ▐░▌       ▐░▌▐░▌ ▄▄▄▄▄▄▄▄
▐░▌       ▐░▌▐░░░░░░░░░░░▌        ▐░░░░░░░░░░░▌▐░▌          ▐░▌       ▐░▌▐░▌▐░░░░░░░░▌
▐░▌       ▐░▌▐░█▀▀▀▀█░█▀▀          ▀▀▀▀▀▀▀▀▀█░▌▐░▌          ▐░▌       ▐░▌▐░▌ ▀▀▀▀▀▀█░▌
▐░▌       ▐░▌▐░▌     ▐░▌                    ▐░▌▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌
▐░█▄▄▄▄▄▄▄█░▌▐░▌      ▐░▌  ▄       ▄▄▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌
▐░░░░░░░░░░▌ ▐░▌       ▐░▌▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
 ▀▀▀▀▀▀▀▀▀▀   ▀         ▀  ▀       ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀

An automated macOS security update script.
EOF

: <<'COMMENT'
## Process

Initialization:
* Check if running as standard user, and request sudo access.

Discovery:
* Check if running latest macOS version.
* Check for automatic system upates.
* Check for automatic app updates.
* Set login banner.

Access:
* Check for Gatekeeper.
* Check firewall status.
* Check admin system settings policy.
* Check on System Integrity Protection (SIP) status.
* Check Filevault Status.
* Loading remote content in Mail setting.
* Check Remote Desktop setting.
* Check remote login setting.
* Check on AirDrop access.
* Check EFI integrity.
* Check auto-open safe downloads setting.
* Check kernel extension user consent setting.
* Login user list policy.

Network:
* Check if SSH is running.
* Update SSH settings.
* Check open ports.
* Restrict remote management.

Applications:
* Search for unapproved software.
* List browsers and extensions.
* Cloud storage applications.

Services:
* List unknown Launch Agents.
* Media insertion actions.
* List cron jobs.

COMMENT

if [ "$(id -u "$(whoami)")" != "0" ]; then
    echo "Dr. Slug needs root! Goodbye."
    exit 1
fi

# Flags

DO_FIX=""
OUTPUT=""
EMAIL=""
VERBOSE=""

# State

LOG=""

initialize() {
	os="$(/usr/bin/uname -s)"

	if [[ "${os}" != "Darwin" ]]; then
		printError "Dr. Slug only works on macOS."
		exit 1
	fi
}

discovery() {

}

access() {

}

network() {

}

applications() {

}

services() {

}

sendMail() {

}

report() {
	echo -e $LOG > "$OUTPUT"
}

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

printWarning() {
  echo -e ${YELLOW}[!]${NC} $1
}

printInfo() {
  echo -e ${BLUE}[i]${NC} $1
}

printError() {
  echo -e ${RED}[x]${NC} $1
}

printSuccess() {
  echo -e ${RED}[x]${NC} $1
}

logEntry() {
	case "$1" in
		info)
			LINE="$(printInfo "$2")"
			;;
		warning)
			LINE="$(printWarning "$2")"
			;;
		error)
			LINE="$(printError "$2")"
			;;
		success)
			LINE="$(printSuccess "$2")"
			;;
		*)
			LINE="$(printError "$2")"
			;;
	esac

  LOG="${LOG}\n${LINE}"
  echo "$LINE"
}

shutdown() {
	echo "Dr. Slug is shutting down..."
	exit 0
}

main() {
	initialize

	declare -r cmd=${1:-"usage"}
	declare -a tests

	tests={}

	trap shutdown SIGINT

	while flag $# -gt 0; do
		case "${cmd}" in
			-h | --help
				echo "* --fix			Fix the issues as they are found."
				echo "* --output		Output a final report of the findings at the specified location."
				echo "* --email		Email a copy of the output to a specified email address."
				echo "* --help; -h 	Prints help message"
				echo "* --version		Prints version info."
				echo "* --verbose		Extra debug messages to stdout."
				exit 0
				;;
			-f | --fix
				DO_FIX=1
				;;
			-o | --output
				shift
				OUTPUT=$1
				;;
			-e | --email
				shift
				EMAIL=$1
				;;
			--version
				echo "Version 1.0"
				;;
			-v | --verbose
				VERBOSE=1
				;;
			*)
				break
				;;
		esac
	done

	initialize
	discovery
	access
	network
	applications
	services
	cleanup
}

main "$@"