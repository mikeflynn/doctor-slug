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
* List recent terminal commands.

Access:
* Check for Gatekeeper.
* Check firewall status.
* Check admin system settings policy.
* Check on System Integrity Protection (SIP) status.
* Check Filevault Status.
* Check kernel extension user consent setting.

Network:
* Check open ports.
* Check if Screen Sharing is running.
* Check if SSH is running.

Services:
* List unknown Launch Agents.
* List cron jobs.

Applications:
* List browsers and extensions.
* Cloud storage applications.

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

THISUSER="$USER"
LOG=""

systemcheck() {
	local os="$(/usr/bin/uname -s)"

	if [[ "${os}" != "Darwin" ]]; then
		logEntry "error" "Dr. Slug only works on macOS."
		exit 1
	fi
}

initialize() {
	echo -e "\nSystem scan starting up...\n"

	if [ "$THISUSER" == "root" ]; then
		THISUSER="$SUDO_USER"
	fi

	echo -e "Running as $THISUSER on $(date '+%Y-%m-%d')\n"
}

# Discovery

getOSVersion() {
	local osv=$(sw_vers | grep ProductVersion | cut -d':' -f2 | xargs)

	logEntry "info" "macOS Version: $osv"
}

getMacAddress() {
	local ma=$(ifconfig en1 | awk '/ether/{print $2}')

	logEntry "info" "MAC Address: $ma"
}

getLocalIP() {
	local ip=$(ipconfig getifaddr en0)

	logEntry "info" "Local IP: $ip"
}

getTerminalHistory() {
	local history=$(history -25)

	logEntry "info" "Terminal History:\n$history\n"
}

getSerialNumber() {
	local sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

	logEntry "info" "Serial Number: $sn"
}

getUpdateStatus() {
	local automaticSysUpdates=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep AutomaticallyInstallMacOSUpdates | awk '{print $3}' | tr -d ';')
	if [ "$automaticSysUpdates" = "0" ]; then
		logEntry "error" "Automatic system updates are turned off."
	else
		logEntry "success" "Automatic system updates are turned on."
	fi

	local pendingUpdates=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep LastRecommendedUpdatesAvailable | awk '{print $3}' | tr -d ';')
	if [ "$pendingUpdates" = "0" ]; then
		logEntry "success" "macOS is up-to-date!"
	else
		logEntry "error" "You have pending macOS updates."
	fi

	local appUpdates=$(defaults read /Library/Preferences/com.apple.commerce.plist AutoUpdate)
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
	local users=$(dscacheutil -q user | grep -A 3 -B 2 -e uid:\ 5'[0-9][0-9]' | grep name | awk '/name:/ {print $2}' | paste -s -d, -)

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
	getTerminalHistory
}

# Access

gatekeeperCheck() {
	gk="$(spctl --status -v)"
	local gk_on="$(echo "$gk" | grep -c "assessments enabled")"
	local di_on="$(echo "$gk" | grep -c "developer id enabled")"

	if [ "$di_on" = "1" ]; then
		logEntry "warning" "Gatekeeper allows apps from App Store and ID'd Developers"
	elif [ "$gk_on" == "1" ]; then
		logEntry "success" "Gatekeeper only allows App Store apps."
	else
		logEntry "error" "Gatekeeper is turned off."
	fi
}

firewallCheck() {
	local fw=$(defaults read /Library/Preferences/com.apple.alf globalstate)

	if [ "$fw" = "0" ]; then
		logEntry "error" "The system firewall is turned off."
	else
		logEntry "success" "The firewall is active."
	fi
}

SIPCheck() {
	if [ "$(csrutil status)" = "System Integrity Protection status: enabled." ]; then
		logEntry "success" "System Integrity Protection (SIP) is active."
	else
		logEntry "error" "System Integrity Protection (SIP) has been turned off."
	fi
}

filevaultCheck() {
	if [ "$(fdesetup status)" = "FileVault is On." ]; then
		logEntry "success" "The disk is encrypted by File Vault."
	else
		logEntry "warning" "File Vault is off and this disk may not be encrypted."
	fi
}

listKernelExts() {
	local exts=$(kextstat | grep -v com.apple | sed 1d | awk '{print $6}' | paste -s -d, -)

	if [ "$exts" = "" ]; then
		logEntry "success" "No active kernel extensions."
	else
		logEntry "warning" "Found installed kernel extensions: $exts"
	fi
}

access() {
	echo -e "\nSystem Access:\n"

	gatekeeperCheck
	firewallCheck
	SIPCheck
	filevaultCheck
	listKernelExts
}

# Network

listOpenPorts() {
	local ports
	ports=$(lsof -Pn -i4 | grep LISTEN | awk '{print $1,$8,$9}')

	logEntry "info" "Open ports identified:\n$ports"
}

screenSharingStatus() {
	local sss
	sss=$([[ -f /etc/RemoteManagement.launchd ]] && echo 'enabled' || echo 'disabled')

	if [ "$sss" = "enabled" ]; then
		logEntry "error" "Screen Sharing service is enabled."
	else
		logEntry "success" "Screen Sharing service is off."
	fi
}

SSHStatus() {
	local status
	status=$(systemsetup -getremotelogin | awk '{print $3}')

	if [ "$status" = "On" ]; then
		logEntry "error" "Remote Login service is on."
	else
		logEntry "success" "Remote Login service is off."
	fi
}

network() {
	echo -e "\nNetwork Connectivity:\n"

	listOpenPorts
	screenSharingStatus
	SSHStatus
}

# Services

listLaunchAgents() {
	local agents
	agents=$(launchctl list | grep -v apple | awk '{print $3}' | sed 1d)

	logEntry "warning" "The following non-Apple launch agents have been found:\n$agents"
}

listCron() {
	local cj
	cj=$(crontab -l)

	if [ "$cj" = "" ]; then
		logEntry "success" "No cron jobs found."
	else
		logEntry "warning" "The following cron jobs were found: $cj"
	fi
}

services() {
	echo -e "\nServices:\n"

	listLaunchAgents
}

# Applications

listBrowsers() {
	if [ -d "/Applications/Google Chrome.app" ]; then
		logEntry "info" "Google Chrome is installed."

		local exts
		exts=$(ls -l ~/Library/Application\ Support/Google/Chrome/Default/Extensions | wc -l | xargs)
		logEntry "info" "Google Chrome extension count: $exts"
	fi

	if [ -d "/Applications/Safari.app" ]; then
		logEntry "info" "Safari is installed."
	fi

	if [ -d "/Applications/Firefox.app" ]; then
		logEntry "info" "Firefox is installed."
	fi
}

fileSharers() {
	if [ -d "/Applications/Dropbox.app" ]; then
		logEntry "info" "Dropbox is installed."
	fi

	if [ -d "/Applications/OneDrive.app" ]; then
		logEntry "info" "OneDrive is installed."
	fi
}

applications() {
	echo -e "\nApplications:\n"

	listBrowsers
	fileSharers
}

# Utils

cleanup() {
	exit 0
}

sendMail() {
	exit 0
}

report() {
	echo -e "$LOG" > "$OUTPUT"
}

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

printWarning() {
  echo -e "${YELLOW}"[!]"${NC}" "$1"
}

printInfo() {
  echo -e "${BLUE}"[i]"${NC}" "$1"
}

printError() {
  echo -e "${RED}"[x]"${NC}" "$1"
}

printSuccess() {
  echo -e "${GREEN}"[✔︎]"${NC}" "$1"
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

		echo -e "$usage"
		exit 0
	fi

	initialize
	discovery
	access
	network
	services
	applications
	cleanup
}

main "$@"