#!/bin/bash

# emojis and symbols
G='\e[1;38;2;20;239;16m'
TP=$'\U0001F9FB'
WHITE_BOLD="\e[1;97m"
CHIAV=$'\U0001F6BD'
QM=$'\U0002753'
BU=$'\U0001F528'
OK=$'\U0001F44D'
BYE=$'\U0001F44B'
GREEN="\e[32m"
G_B="\e[1;32m"
YELLOW_BOLD="\e[1;33m"
YELLOW="\e[33m"
RESET="\e[0m"
RED="\e[31m"
R_B="\e[1;31m"
ALERT=$'\U0001F534'
ALT=$'\U0001F590'

# functions

# Minimal Banner
function min_banner () {

echo -e "\n\n${G_B}/-------------------**${RESET} ${G} A.C. - ReconX ${RESET}${G_B}**--------------------\\"
echo -e "|----------**${RESET}  ${WHITE_BOLD}Infrastructure Enumeration Tool  ${RESET}${G_B}**----------|"
echo -e "\-------------------**${RESET}   ${R_B} v 1.0.0   ${RESET}  ${G_B}**--------------------/${RESET}\n\n"

}

min_banner

# check current workind directory
function pwd_check () {
	if [[ ! "$(basename "$PWD")" == "ac-reconx" && ! -f "./ac-reconx-cli" ]];then
		echo -e "\n${ALT}${YELLOW} Please run the installer from its root directory${RESET}"
		exit 1
	fi
}

# tools check
## nc, tmux, nmap, zip
function tool_check () {
	# check if tool are installed and if not ask for sudo permissions to download them from the APT repository
	if command -v tmux >/dev/null && command -v nc >/dev/null && command -v nmap >/dev/null && command -v zip >/dev/null;then
		echo -e "\n${G_B}${OK} Tools requirements satisfied!${RESET}"
        else
		echo -e "${ALT}${YELLOW_BOLD} One or more tools are missing. Need sudo privileges to install them.${RESET}"
		while true;do
			echo -e -n "\n${YELLOW_BOLD} Do you want to proceed? (y/n) ${RESET}"
			read -r -p "" SP
			if [[ ! "$SP" =~ ^(y|yes|n|no)$ ]];then
				echo -e "\n${YELLOW} Please provide a valid answer.${RESET}"
			else
				break
			fi
		done
		if [[ ! "${SP,,}" =~ ^(y|yes)$ ]];then
			exit 0
		fi

		if ! sudo -v;then
			echo -e "\n${ERROR}${RED} Failed to authenticate with sudo.${RESET}"
			exit 1
		fi

		# update first
		sudo apt update -y >/dev/null 2>&1

		# check each tool is installed and eventually install it to continue
		tools=("nc" "nmap" "tmux" "zip")
		for tool in "${tools[@]}";do
			if ! command -v "$tool" >/dev/null;then
				if [[ "$tool" == "nc" ]];then
					tool="netcat-openbsd"
				fi

				echo -e "\n${YELLOW}[!] \"$tool\" tool not installed. Install it to continue.${RESET}"
		                while true;do
		                        read -r -p "[?] Install $tool (y/n) ? " R1
		                        if [[ ! "${R1,,}" =~ ^(y|yes|n|no)$ ]];then
						echo -e "\n${YELLOW} Please provide a valid answer.\n${RESET}"
					else
						break
					fi
				done

				if [[ "${R1,,}" =~ ^(y|yes)$ ]];then
					if ! sudo apt install "$tool" -y >/dev/null 2>&1;then
						echo -e "\n${ERROR}${RED} Failed to install \"$tool\" .${RESET}"
						exit 1
					else
						echo "$tool" >> "./.pkgs_list"
						echo -e "\n${BU}${GREEN} \"$tool\" successfully installed!${RESET}"
					fi
				else
		                	echo -e "\n${BYE}${YELLOW}Tool requirements not satisfied.${RESET}"
					exit 1
				fi
			fi
		done

	fi

}

function already_installed_bash () {
	if [[ -e "$HOME/.local/share/bash-completion/completions/ac-reconx-cli" ]] && grep -q "#AC-RECONX#" "$HOME/.bashrc";then
		re_salut
	fi
}

function already_installed_zsh () {
	if [[ -e "$HOME/.zsh/completions/_ac-reconx" ]] && grep -q "#AC-RECONX#" "$HOME/.zshrc" && [[ -L "$HOME/.local/bin/ac-reconx-cli" ]];then
		re_salut
	fi
}


function salut () {
	echo -e "\n${OK}${G_B} Installation completed. Ready to roll!${RESET}  ${TP}\n   Open a new shell to use this \"chiavica\" ${CHIAV}"
	echo -e "\n${BYE}${G_B} Appreciate the attention you put it in my tool. Thanks!\n${RESET}   For any advice or suggestion contact me.\n\nMy best regards,\n\t${WHITE_BOLD}alexc.cybersec@gmail.com${RESET}"
	exit 0
}

function re_salut () {
	echo -e "\n${OK}${G_B} Already installed and ready to roll!${RESET}   ${TP}\n   Open a new shell to use this \"chiavica\" ${CHIAV}"
	echo -e "\n${BYE}${G_B} Appreciate the attention you put it in my tool. Thanks!\n${RESET}   For any advice or suggestion contact me.\n\nMy best regards,\n\t${WHITE_BOLD}alexc.cybersec@gmail.com${RESET}"
	exit 0
}

# give ac-reconx-cli execution bit
function script_execution () {
	if [[ -f "./ac-reconx-cli" ]];then
		chmod +x "./ac-reconx-cli"
	else
		echo -e "\n{ALERT}${RED} Error: missing ac-reconx-cli script file. Download the github repo again.${RESET}"
		exit 1
	fi
}


# user with bash shell, add this tool directory to executable PATH

function add_path () {
	# ask to add the directory tool to user PATH
	echo -e "\n${ALT}${YELLOW_BOLD} Add \"ac-reconx-cli\" to your PATH to run the tool globally? (Y/N)${RESET}"
	while true;do
		read -r -p "  Answer:  "
		if [[ "${REPLY,,}" =~ ^(y|n)$  ]];then
			break
		else
			echo -e "\n${YELLOW}  Provide a valid answer to continue.${RESET}"
		fi
	done

	if [[ "$REPLY" == "y" ]];then
		if ! grep -q "#AC-RECONX#" "$HOME/.bashrc";then
			if echo -e "#AC-RECONX#\nexport PATH=\$PATH:$PWD\n$(cat $HOME/.bashrc)" > "$HOME/.bashrc.tmp" && mv "$HOME/.bashrc.tmp" "$HOME/.bashrc";then
				echo -e "\n${BU}${GREEN} Tool directory successfully appended to your executable PATH.${RESET}"
				sleep 2
			else
				echo -e "\n${RED} Error: couldn't append tool dir to your executable PATH.${RESET}"
	                        echo -e "${YELLOW} You can execute it inside ac-reconx directly.${RESET}"
				sleep 2
			fi
		else
			echo -e "\n${ALT}${YELLOW} bash completion is already set in your \"$HOME/.bashrc\" file ${RESET}"
			sleep 2
		fi
	else
		echo -e "\n${YELLOW} You can execute it inside ac-reconx directory directly.${RESET}"
	fi
}


# for zsh users copy the executable to $HOME/.local/bin and create a symbolic link between ac-reconx-cli inside its tool root directory and $HOME/.local/bin/ac-reconx-cli
function sym_link () {
	# Adding a symbolic link to the executable
	echo -e "\n${ALT}${YELLOW_BOLD} Create a sym link between tool <--> executable PATH, to run it globally? (Y/N)${RESET}"

	while true;do
		read -r -p "  Answer:  "
		if [[ "${REPLY,,}" =~ ^(y|n)$  ]];then
			break
		else
			echo -e "\n${YELLOW}  Provide a valid answer to continue.${RESET}"
		fi
	done

	if [[ "$REPLY" == "y" ]];then
		# check if $HOME/.local/bin exist, if yes create a link between ac-reconx-cli and this location
		## if not, create the dir and then create the link
		if [[ ! -d "$HOME/.local/bin" ]];then
			if mkdir -p "$HOME/.local/bin";then
				echo -e "\n${BU}${GREEN} Successfully created directory \"$HOME/.local/bin/\" ${RESET}"
				sleep 2
			else
				echo -e "\n${RED} Error: could not create directory \"$HOME/.local/bin\".${RESET}"
				echo -e "${YELLOW} You can execute ac-reconx-cli directly inside its original dir.${RESET}"
				sleep 2
				return
			fi
		fi

		# check if HOME/.local/bin is already in the $USER path
		if echo "$PATH" | grep "$HOME/.local/bin" >/dev/null;then
			if ln -sfn "$PWD/ac-reconx-cli" "$HOME/.local/bin/ac-reconx-cli";then
				echo -e "\n${BU}${GREEN} Symbolic link succesfully created.${RESET}"
				ls -l "$HOME/.local/bin/ac-reconx-cli"
				sleep 2
			else
				echo -e "\n${RED} Error: could not create symbolic link.${RESET}"
				echo -e "${YELLOW} You can execute ac-reconx-cli directly inside its original dir.${RESET}"
				sleep 2
			fi
		else
			echo "export PATH=$PATH:$HOME/.local/bin" >> "$HOME/.zshrc"
			if ln -sfn "$PWD/ac-reconx-cli" "$HOME/.local/bin/ac-reconx-cli";then
				echo -e "\n${BU}${GREEN} Symbolic link succesfully created.${RESET}"
				ls -l "$HOME/.local/bin/ac-reconx-cli"
				sleep 2
			else
				echo -e "\n${RED} Error: could not create symbolic link.${RESET}"
				echo -e "${YELLOW} You can execute ac-reconx-cli directly inside its original dir.${RESET}"
				sleep 2
			fi
		fi
	else
		echo -e "${YELLOW} You can execute ac-reconx-cli directly inside its original dir.${RESET}"
	fi
}




# check current working directory
pwd_check

# check tools requirements
tool_check
sleep 2

# check in which shell the user is working

## zsh shell users
if [[ "$(basename "$SHELL")" == "zsh"  ]];then
	# give ac-reconx-cli exec bit
	script_execution
	# check if tool is already installed on $USER
	already_installed_zsh
	if [[ ! -d "$HOME/.zsh/completions/" ]];then
		if mkdir -p "$HOME/.zsh/completions/";then
			echo -e "\n${BU}${GREEN} Directory \"$HOME/.zsh/completions/\" successfully created.${RESET}"
			sleep 2
		else
			echo -e "\n${ALERT}${RED}Error: directory \"$HOME/.zsh/completions/\" creation failed.${RESET}"
			exit 1
		fi
	fi
	if [[ -f "./zsh/_ac-reconx" ]];then
		if [[ ! -f "$HOME/.zsh/completions/_ac-reconx" ]];then
			if cp "./zsh/_ac-reconx" "$HOME/.zsh/completions/";then
				chmod 644 "$HOME/.zsh/completions/_ac-reconx"
				echo -e "\n${BU}${GREEN} File \"./zsh/_ac-reconx\" successfully copied in \"$HOME/.zsh/completions/\".${RESET}"
				sleep 2

				# adding this line at the beginning of your ~/.zshrc fpath=($HOME/.zsh/completions $fpath)
				## checking if the string is already in .zshrc $USER file
				if ! grep -qF "#AC-RECONX#" "$HOME/.zshrc";then
					echo -e "#AC-RECONX#\nfpath=($HOME/.zsh/completions \$fpath)\n$(cat ~/.zshrc)" > "$HOME/.zshrc.tmp" && mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"
					echo -e "\n${OK}${GREEN} Successfully added this strings in your \"$HOME/.zshrc\" file:${RESET}"
					echo -e '#AC-RECONX#\nfpath=($HOME/.zsh/completions $fpath)'
					sleep 2

					# Remove the completion file and cache
					rm -f ~/.cache/zcompdump*

					# add to executable PATH?
					sym_link
				else
					echo -e "\n${ALT}${YELLOW} zsh completion is already set in your \"$HOME/.zshrc\" file ${RESET}"
					sleep 2
				fi
				salut
			else
				echo -e "\n${ALERT}${RED} File \"HOME/.zsh/completions/_ac-reconx\" can't be copied to \"$HOME/.zsh/completions/\".${RESET}"
				exit 1
			fi
		fi
	fi

# bash shell users
elif [[ "$(basename "$SHELL")" == "bash"  ]];then
	# give ac-reconx-cli exec bit
	script_execution
	# check if tool is already installed
	already_installed_bash
	# add completion for BASH shells
	if ! dpkg -l bash-completion >/dev/null;then
		echo -e "${QM}${YELLOW} You need bash-completion to enable autocompletion.\nInstall it? (y/n)${RESET}"
		while true;do
			read -r -p ""
			if [[ "${REPLY,,}" =~ ^(y|n)$ ]];then
				if [[ "$REPLY" == "y" ]];then
					echo -e "\n${ALT} Now I will ask for sudo priv to install bash-completion...${RESET}"
					if sudo apt install bash-completion -y; then
						echo -e "\n${G_L}${GREEN} Succesfully installed.${RESET}"
					else
						echo -e "\n${ALERT}${RED}Error: installation failed.${RESET}"
						exit 1
					fi
				else
					echo -e "\n${BYE}${YELLOW} Bye!${RESET}"
					exit 0
				fi
			else
				echo -e "\n${ALT}${YELLOW} Not a valid selection.\n Type again:${RESET}"
			fi
		done
	fi

	if [[ ! -d "$HOME/.local/share/bash-completion/completions" ]];then
		echo -e "\n${BU}${GREEN}Creating directory: \"$HOME/.local/share/bash-completion/completions\" ${RESET}"
		if ! mkdir -p "$HOME/.local/share/bash-completion/completions" 2>/dev/null;then
			echo -e "\n${ALERT}${RED}Error: can't create \"$HOME/.local/share/bash-completion/completions\" ${RESET}"
			exit 1
		fi
	fi

	if [[ -f "./bash/ac-reconx_bc" ]];then
		if [[ -f "$HOME/.local/share/bash-completion/completions/ac-reconx-cli" ]];then
			echo -e "${ALT}${YELLOW} file \"$HOME/.local/share/bash-completion/completions/ac-reconx-cli\" already exist.${RESET}"
		else
			if cp "./bash/ac-reconx_bc" "$HOME/.local/share/bash-completion/completions";then
				mv "$HOME/.local/share/bash-completion/completions/ac-reconx_bc" "$HOME/.local/share/bash-completion/completions/ac-reconx-cli"
				echo -e "\n${BU}${GREEN} Successfully renamed \"./bash/ac-reconx_bc\" into \"ac-reconx-cli\" and copied into \"$HOME/.local/share/bash-completion/completions\"${RESET}"
				sleep 2
			else
				echo -e "\n${ALERT}${RED}Error: couldn't copy \"./bash/ac-reconx_bc\" into \"$HOME/.local/share/bash-completion/completions\"${RESET}"
				exit 1
			fi
		fi
	else
		echo -e "\n${ALT}${YELLOW} Error: no file \"./bash/ac-reconx_bc\" in your CWD.${RESET}"
		exit 1
	fi

	if [[ -f "./ac-reconx-cli" ]];then
		chmod 644 "./ac-reconx-cli"
		chmod +x "./ac-reconx-cli"
		# add sym link to executable PATH?
		add_path
		salut
	else
		echo -e "\n${ALERT}${RED} Error: no file \"./ac-reconx.sh\" in your CWD.${RESET}"
		exit 1
	fi

else
	echo -e "\n${ALT}${YELLOW} Completion suggestion can not be implemented.\nInstall \"zsh\" or \"bash\" to continue or eventually just install bash to run the script directly.${RESET}"
	exit 1

fi
