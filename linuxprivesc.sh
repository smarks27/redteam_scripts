#!/bin/bash

# Highlight Styles
RED_HIGHLIGHT='\e[41m'
ORANGE_HIGHLIGHT='\e[48;5;202m'
YELLOW_HIGHLIGHT='\e[43m'
GREEN_HIGHLIGHT='\e[48;5;70m'
CYAN_HIGHLIGHT='\e[48;5;37m'
BLUE_HIGHLIGHT='\e[48;5;19m'
PURPLE_HIGHLIGHT='\e[48;5;91m'

# Font Colors
LIGHTCYAN='\e[96m'
BLACK='\e[30m'

# Font Styles
BOLD='\e[1m'
UNDERLINED='\e[4m'
NORMAL='\e[0m'

# Functions
indent() { sed 's/^/    /'; }
valid_users () {
    # Add all users from /etc/passwd to array
    declare -a users=()
    for line in $(cat /etc/passwd | cut -d ":" -f 1); do users+=("$line"); done

    # Initialize variables
    count=0
    final_string=""

    # Loop through user array and add the user's name followed by 
    # a "\n" character to a string for every 4th user and the user's name
    # followed by a "|" character for every other user
    for (( i=0; i<${#users[@]}; i++ ))
    do     
        ((count = count + 1))
        if [[  $(($count % 4)) -eq 0  ]]; then
            updated_char="\n"
            final_string+=${users[$i]}
            final_string+=$updated_char
        else
            final_string+=${users[$i]}
            final_string+="|"
        fi
    done

    # Print out table format
    printf "$final_string" | column -t -s "|" | indent | indent
}
writable_folders() {
    declare -a folders=()
    for line in $(find / -writable 2>/dev/null | cut -d "/" -f 2 | sort -u); do folders+=("$line"); done

    # Initialize variables
    count=0
    final_string=""

    # Loop through user array and add the user's name followed by 
    # a "\n" character to a string for every 4th user and the user's name
    # followed by a "|" character for every other user
    for (( i=0; i<${#folders[@]}; i++ ))
    do
        directory="/"
        directory+=${folders[$i]}
        if [ -d $directory  ]; then
            ((count = count + 1))
            if [[  $(($count % 4)) -eq 0  ]]; then
                updated_char="\n"
                final_string+=${folders[$i]}
                final_string+=$updated_char
            else
                final_string+=${folders[$i]}
                final_string+="|"
            fi
        fi
    done

    # Print out table format
    printf "$final_string" | column -t -s "|" | indent
}
newline() {
    echo ""
}
# SYSTEM AND USER INFORMATION
echo -e "${RED_HIGHLIGHT}${BOLD}System and User Information:${NORMAL}\n"
echo -ne "${UNDERLINED}Hostname:${NORMAL}  " | indent
hostname
echo -ne "${UNDERLINED}Kernel Version:${NORMAL}  " | indent
uname -r
echo -ne "${UNDERLINED}System Architecture:${NORMAL}  " | indent
uname -m
echo -ne "${UNDERLINED}OS Version:${NORMAL}  " | indent
uname -v
echo -ne "${UNDERLINED}User and Group ID:${NORMAL}  " | indent
id
echo -ne "${UNDERLINED}Sudo Version:${NORMAL}  " | indent
sudo -V | grep "Sudo ver"
echo -ne "${UNDERLINED}Sudoers File Permissions:${NORMAL}  " | indent
ls -la /etc/sudoers
newline
echo -e "${UNDERLINED}Valid Users:${NORMAL}" | indent
valid_users
newline
echo -e "${UNDERLINED}Sudo Permissions:${NORMAL}" | indent
sudo -l | indent | indent
newline
echo -e "${UNDERLINED}Environment Variables:${NORMAL}" | indent
env | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | indent | indent | cut -c1-$(stty size </dev/tty | cut -d ' ' -f2)
newline

# SUID
echo -e "${ORANGE_HIGHLIGHT}${BOLD}${BLACK}SUID Files:${NORMAL}\n" 
find / -perm /4000 2>/dev/null | indent
echo -e "\nMore Information: ${LIGHTCYAN}${UNDERLINED}https://gtfobins.github.io/#+suid${NORMAL}; ${LIGHTCYAN}${UNDERLINED}https://book.hacktricks.xyz/linux-hardening/privilege-escalation/euid-ruid-suid${NORMAL}\n" | indent

# CRONTAB
echo -e "${YELLOW_HIGHLIGHT}${BOLD}${BLACK}CRON Tab:${NORMAL}\n"
echo -e -n "${UNDERLINED}Permissions:${NORMAL}  " | indent
ls -la /etc/crontab
cat /etc/crontab | indent
echo -e "\nMore Information: ${LIGHTCYAN}${UNDERLINED}https://book.hacktricks.xyz/linux-hardening/privilege-escalation#scheduled-jobs${NORMAL}\n" | indent

# CAPABILITIES
echo -e "${GREEN_HIGHLIGHT}${BOLD}${BLACK}Capabilities:${NORMAL}\n"
getcap -r / 2>/dev/null | indent
echo -e "\nMore Information: ${LIGHTCYAN}${UNDERLINED}https://book.hacktricks.xyz/linux-hardening/privilege-escalation/linux-capabilities${NORMAL}\n" | indent

# PATH
echo -e "${CYAN_HIGHLIGHT}${BOLD}${BLACK}PATH:${NORMAL}\n"
echo "$PATH" | indent
newline
echo -e "More Information: ${LIGHTCYAN}${UNDERLINED}https://book.hacktricks.xyz/linux-hardening/linux-environment-variables${NORMAL}\n" | indent

# Writable Folders
echo -e "${BLUE_HIGHLIGHT}${BOLD}Writable Folders:${NORMAL}"
newline
writable_folders
newline

# Network Shares
echo -e "${PURPLE_HIGHLIGHT}${BOLD}Network Shares:${NORMAL}"
newline
if ! [ -f "/etc/exports" ]; then
    echo "No network shares exist" | indent
else
    cat /etc/exports | indent
fi

newline
echo -e "More Information: ${LIGHTCYAN}${UNDERLINED}https://book.hacktricks.xyz/linux-hardening/privilege-escalation/nfs-no_root_squash-misconfiguration-pe${NORMAL}\n" | indent