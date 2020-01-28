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

Security:
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

discovery() {

}

sendMail() {

}

report() {

}

printWarning() {
	echo "[i] $1"
}

printInfo() {
	echo "[i] $1"
}

printError() {
	echo "[x] $1"
}

initialize() {
	os="$(/usr/bin/uname -s)"

	if [[ "${os}" != "Darwin" ]]; then
		printError "[x] Dr. Slug only works on macOS."
		exit 1
	fi
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
				echo "* --fix			Actually fix the issues found in realtime."
				echo "* --output		Output a final report of the findings at the specfied location."
				echo "* --email		Email a copy of the output to a specified email address."
				echo "* --help; -h 	Prints help message"
				echo "* --version		Prints version info."
				echo "* --verbose		Extra deubg messages to stdout."
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

	discovery


}

main "$@"