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
* List MAC Addres
* List local IP
* List Serial Number
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

DO_FIX=false
OUTPUT=""
VERBOSE=false

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

getMacAddress() {
	ma=$(ifconfig en1 | awk '/ether/{print $2}')

	logEntry "info" "MAC Address: $ma"
}

getLocalIP() {
	ip=$(ipconfig getifaddr en0)

	logEntry "info" "Local IP: $ip"
}

getSerialNumber() {
	sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

	logEntry "info" "Serial Number: $sn"
}

getUpdateStatus() {
	automaticSysUpdates=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep AutomaticallyInstallMacOSUpdates | awk '{print $3}' | tr -d ';')
	if [ "$automaticSysUpdates" = "0" ]; then
		logEntry "error" "Automatic system updates are turned off."
	else
		logEntry "success" "Automatic system updates are turned on."
	fi

	pendingUpdates=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep LastRecommendedUpdatesAvailable | awk '{print $3}' | tr -d ';')
	if [ "$pendingUpdates" = "0" ]; then
		logEntry "success" "macOS is up-to-date!"
	else
		logEntry "error" "You have pending macOS updates."
	fi

	appUpdates=$(defaults read /Library/Preferences/com.apple.commerce.plist AutoUpdate)
	if [ "$appUpdates" = "0" ]; then
		logEntry "error" "Automatic application updates are turned off."
	else
		logEntry "success" "Automatic application updates are turned on."
	fi
}

fixUpdateStatus() {
	/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool TRUE
	/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool TRUE
	/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticallyInstallMacOSUpdates -bool TRUE
	/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool TRUE
	/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool TRUE
	/usr/bin/defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool TRUE

	logEntry "success" "Automatic update settings have been updated."
}

listUsers() {
	users=$(dscacheutil -q user | grep -A 3 -B 2 -e uid:\ 5'[0-9][0-9]' | grep name | awk '/name:/ {print $2}' | paste -s -d, -)

	logEntry "info" "Local users: $users"
}

checkPolicyBanner() {
	if [ -f "/Library/Security/PolicyBanner" ]; then
		logEntry "success" "Policy banner is in place."
	else
		logEntry "warning" "No policy banner has been set."
	fi
}

discovery() {
	echo -e "System Discovery:\n"

	getOSVersion
	getMacAddress
	getLocalIP
	getSerialNumber
	listUsers
	getUpdateStatus
	checkPolicyBanner
}

# Access

access() {
	echo -e "\nSystem Access:\n"
	logEntry "warning" "Access tests are not yet implemented."
}

# Network

network() {
	echo -e "\nNetwork Connectivity:\n"
	logEntry "warning" "Network tests are not yet implemented."
}

# Applications

applications() {
	echo -e "\nApplications:\n"
	logEntry "warning" "Applications tests are not yet implemented."
}

# Services

services() {
	echo -e "\nServices:\n"
	logEntry "warning" "Services tests are not yet implemented."
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