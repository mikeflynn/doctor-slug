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

: <<'END'
## Process

* Check if running as standard user, and request sudo access.
* Check if running latest macOS version.
* Check for automatic system upates.
* Check for automatic app updates.
* Check for Gatekeeper.
* Check firewall status.
* Check admin system settings policy.
* Check on System Integrity Protection (SIP) status.
* Check Filevault Status
* Loading remote content in Mail setting.
* Check Remote Desktop setting.
* Check remote login setting.
* Check auto-open safe downloads setting.
* Check on AirDrop access.
* Check kernel extension user consent setting.
* Check EFI integrity.
* Check if SSH is running.
* List unknown Launch Agents.
* Search for unapproved software.
END

function sendMail {

}

function report {

}

function printResult {

}

function initialize {

}

function shutdown {

}

function main {
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
				export FIX=1
				;;
			-o | --output
				shift
				export OUTPUT=$1
				;;
			-e | --email
				shift 
				export EMAIL=$1
				;;
			--version
				echo "Version 1.0"
				;;
			-v | --verbose
				export VERBOSE=1
				;;
			*)
				break
				;;
		esac
	done
}

main "$@"