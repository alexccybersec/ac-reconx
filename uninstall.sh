#!/bin/bash

# colors and symbols
G='\e[1;38;2;20;239;16m'
WHITE_BOLD="\e[1;97m"
QM=$'\U0002753'
ALERT=$'\U0001F534'
GREEN="\e[32m"
RED="\e[31m"
R_B='\e[1;31m'
CK=$'\U0002705'
FCK=$'\U000274C'
OK=$'\U0001F44D'
BYE=$'\U0001F44B'
G_B="\e[1;32m"
YELLOW="\e[33m"
YELLOW_BOLD="\e[1;33m"
RESET="\e[0m"

# Minimal Banner
function min_banner () {

echo -e "\n\n${G_B}/-------------------**${RESET} ${G} A.C. - ReconX ${RESET}${G_B}**--------------------\\"
echo -e "|----------**${RESET}  ${WHITE_BOLD}Infrastructure Enumeration Tool  ${RESET}${G_B}**----------|"
echo -e "\-------------------**${RESET}   ${R_B} v 1.0.0   ${RESET}  ${G_B}**--------------------/${RESET}\n\n"

}

min_banner


# check cwd
if [[ ! "$(basename "$PWD")" == "ac-reconx"  && ! -e "./.gitignore" && ! -e "./ac-reconx-cli" ]];then
	echo -e "\n${YELLOW} Please run \"./uninstall.sh\" within \"ac-reconx\" tool directory.${RESET}"
	exit 1
fi

# remove link from ~/.local/bin
link_path="$HOME/.local/bin/ac-reconx-cli"

# strings added in .bashrc file
added_strings="#AC-RECONX#\|export PATH=\$PATH:$PWD"

# remove tool directory at the end
function remove_root_dir () {
	if rm -rf ../ac-reconx 2>/dev/null;then
		echo -e "\n${CK}${GREEN} Successfully removed tool directory."
		sleep 1
	else
		echo -e "\n${ALERT}${RED} Error: could't remove \"ac-reconx\" tool directory.\n   Uninstallation FAILED.${RESET}"
		exit 1
	fi
}

# removing packages that were not present when ac-reconx-cli cmd was executed for the first time
function remove_pkgs () {
	if [[ -e "./.pkgs_list" ]];then
		echo -e "\n${QM}${YELLOW_BOLD} This packages were installed the first time you run this tool:${RESET}"
		cat "./.pkgs_list"
		while true;do
			echo -e -n "\n${YELLOW} remove them? (y/n) ${RESET}"
			read -r -p ""
			if [[ ! "${REPLY,,}" =~ ^(y|yes|n|no)$ ]];then
				echo -e "\n${YELLOW} Please provide a valid answer to continue.${RESET}"
			else
				break
			fi
		done

		if [[ "$REPLY" =~ ^(y|yes)$ ]];then
			echo -e "\n${ALT}${YELLOW_BOLD} Need sudo privileges to remove pkgs.${RESET}"
			if ! sudo -v;then
	                        echo -e "\n${ALERT}${RED} Failed to authenticate with sudo.${RESET}"
				echo -e "\n${YELLOW} Suggestion: remove them manually.${RESET}"
			else
				while IFS= read -r tool;do
					if [[ "$tool" == "nc" ]];then
						tool="netcat-openbsd"
					fi
					if ! sudo apt purge "$tool" -y >/dev/null 2>&1;then
						echo -e "\n${ALERT}${RED} Error: failed to remove \"$tool\" tool${RESET}"
					else
						echo -e "\n${CK}${GREEN} Tool \"$tool\" has been removed.${RESET}"
					fi
				done < "./.pkgs_list"
			fi
		else
			echo -e "\n${FCK}${YELLOW} Required/installed tools will not be removed.${RESET}"
		fi
	fi
}

# ask to remove tools that were installed during ac-reconx-cli first execution
remove_pkgs

# check SHELL and remove artifacts
# zsh users
if [[ "$(basename "$SHELL")" == "zsh" ]];then
	if grep -q "#AC-RECONX#\|fpath=($HOME/.zsh/completions \$fpath)" "$HOME/.zshrc" ;then
		grep -v "#AC-RECONX#\|fpath=($HOME/.zsh/completions \$fpath)" "$HOME/.zshrc" > "$HOME/.zshrc.tmp"
		if mv "$HOME/.zshrc.tmp" "$HOME/.zshrc";then
			echo -e "\n${CK}${GREEN} Successfully removed added strings from $HOME/.zshrc"
			R1="true"
			sleep 1
		else
			echo -e "\n${FCK}${RED} Error: failed to remove added strings $HOME/.zshrc"
			R1="false"
			sleep 1
		fi
	else
		R1_cleaned="true"
	fi

	if [[ -e "$HOME/.zsh/completions/_ac-reconx" ]];then
		if rm -r "$HOME/.zsh/completions/_ac-reconx";then
			echo -e "\n${CK}${GREEN} Successfully removed $HOME/.zsh/completions/_ac-reconx${RESET}"
			R2="true"
			sleep 1
		else
			echo -e "\n${FCK}${RED} Error: failed to remove $HOME/.zsh/completions/_ac-reconx${RESET}"
			R2="false"
			sleep 1
		fi
	elif [[ ! -e "$HOME/.zsh/completions/_ac-reconx" ]];then
		R2_cleaned="true"
	fi

	if [[ -L "$link_path" ]];then
		if rm -r "$link_path";then
			echo -e "\n${CK}${GREEN} Symbolic link to ac-reconx-cli executable correctly removed from your PATH.${RESET}"
			R3="true"
			sleep 1
		else
			echo -e "\n${FCK}${RED} Error: failed to remove ac-reconx-cli executable link.${RESET}"
			R3="false"
			sleep 1
		fi
	else
		R3_cleaned="true"
	fi

	if remove_root_dir;then
		R4="true"
	else
		R4="false"
	fi

	# check file/dir deletion
	if [[ "$R1" == "true" && "$R2" == "true" && "$R3" == "true" && "$R4" == "true" ]];then
		echo -e "\n${BYE}${G_B} Uninstall completed successfully.${RESET}"
		exit 0
	elif [[ "$R1_cleaned" == "true" && "$R2_cleaned" == "true" && "$R3_cleaned" == "true" && "$R4" == "true" ]];then
		echo -e "\n${YELLOW} Nothing else to remove.{RESET}"
	else
		echo -e "\n${ALERT}${RED} Error: couldn't clean all the tool artifacts.${RESET}"
		echo -e "\n${YELLOW} Please execute this checks, and eventually remove those strings/files:${RESET}"
		echo -e "\t1)  sed -n 1,2p $HOME/.zshrc"
		echo -e "\t2)  ls -l $HOME/.zsh/completions/_ac-reconx 2>/dev/null || echo 'File does not exist.'"
		echo -e "\t3)  ls -l $link_path 2>/dev/null || echo 'Link to ac-reconx-cli does not exist.'"
		exit 1
	fi

# bash users
elif [[ "$(basename "$SHELL")" == "bash" ]];then
	if [[ -e "$HOME/.local/share/bash-completion/completions/ac-reconx-cli" ]];then
		if rm -r "$HOME/.local/share/bash-completion/completions/ac-reconx-cli";then
			echo -e "\n${CK}${GREEN} Successfully removed $HOME/.local/share/bash-completion/completions/ac-reconx-cli${RESET}"
			R1="true"
			sleep 1
		else
			echo -e "\n${FCK}${RED} Error: failed to remove $HOME/.local/share/bash-completion/completions/ac-reconx-cli${RESET}"
			R1="false"
			sleep 1
		fi
	else
		R1_cleaned="true"
	fi

# check .bashrc file and eventually delete strings added during installation
	if grep -q "$added_strings" "$HOME/.bashrc";then
		if grep -v "$added_strings" "$HOME/.bashrc" > "$HOME/.bashrc.tmp";then
			mv "$HOME/.bashrc.tmp" "$HOME/.bashrc" && echo -e "\n${CK}${GREEN} Successfully cleaned your .bashrc file.${RESET}"
			R2="true"
			sleep 1
		else
			R2="false"
			echo -e "\n${FCK}${RED} Error: failed to remove added strings in \"$HOME/.bashrc\" file."
			sleep 1
		fi
	else
		R2_cleaned="true"
	fi

	if remove_root_dir;then
		R3="true"
	else
		R3="false"
	fi

	if [[ "$R1" == "true" && "$R2" == "true" && "$R3" == "true" ]];then
		echo -e "\n${OK}${G_B} Uninstall completed successfully.${RESET}"
		exit 0
	elif [[ "$R1_cleaned" == "true" && "$R2_cleaned" == "true" && "$R3" == "true" ]];then
		echo -e "\n${YELLOW} Nothing else to remove.{RESET}"
	else
		echo -e "\n${ALERT}${RED} Error: couldn't clean all the tool artifacts."
		echo -e "\n${YELLOW} Please execute this checks and eventually remove files manually:${RESET}"
		echo -e "\t1)  ls -l $HOME/.local/share/bash-completion/completions/ac-reconx-cli 2>/dev/null || echo 'File does not exist.'"
		echo -e "\t2)  sed -n 1,2p $HOME/.bashrc"
		exit 1
	fi

fi
