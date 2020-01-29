#!/usr/bin/env bash

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
* Check macOS version.
* Check for automatic system upates.
* Check for automatic app updates.
* Set login banner.
* List users.

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
VERBOSE=""

# State

LOG=""

systemcheck() {
	os="$(/usr/bin/uname -s)"

	if [[ "${os}" != "Darwin" ]]; then
		logEntry "error" "Dr. Slug only works on macOS."
		exit 1
	fi
}

initialize() {
	echo -e "\nSystem scan starting up...\n"
}

# Discovery

getOSVersion() {
	osv=$(sw_vers | grep ProductVersion | cut -d':' -f2 | xargs)

	logEntry "info" "You are running macOS $osv"
}


discovery() {
	getOSVersion
}

# Access

access() {
	logEntry "info" "Access tests are not yet implemented."
}

# Network

network() {
	logEntry "info" "Network tests are not yet implemented."
}

# Applications

applications() {
	logEntry "info" "Applications tests are not yet implemented."
}

# Services

services() {
	logEntry "info" "Services tests are not yet implemented."
}

cleanup() {
	exit 0
}

# Utils

sendMail() {
	exit 0
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
	systemcheck

	tests={}

	trap shutdown SIGINT

	if [ "$1" = "-h" ]; then
		usage="\n
Flags:\n
\t-h 	--> Prints this help message\n
\n
\tEx: ./drslug.sh -h\n
\n
Options:\n
\tEMAIL: Optionally email the report to this user.\n
\tFIX: If true, will apply fixes where needed as the tests are run.\n
\tOUTPUT: If set, overrides the default report output location.\n
\n
\tEx: sudo EMAIL=test@test.com ./drslug.sh\n
		"

		echo -e $usage
		exit 0
	fi

	initialize
	discovery
	access
	network
	applications
	services
	cleanup
}

main "$@"