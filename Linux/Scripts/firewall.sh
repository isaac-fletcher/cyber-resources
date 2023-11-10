#!/bin/bash
# Aaron Sprouse, Tim Koehler, Isaac Fletcher
# Clemson CUCyber
# 2023

# Function to add a rule
add_rule() {
    echo "Adding a new UFW rule:"
    read -p "Enter rule (e.g., 'allow 22/tcp'): " rule
    ufw $rule
    echo "Rule added: $rule"
}

# Function to remove a rule
remove_rule() {
    echo "Removing a UFW rule:"
    read -p "Enter rule to remove (e.g., 'allow 22/tcp'): " rule
    ufw delete $rule
    echo "Rule removed: $rule"
}

# Creates a backup of all necessary ufw files
backup_ufw() {	
	cp /etc/default/ufw default_ufw_bak
	cp /etc/ufw/user.rules user_rules_bak
	cp /etc/ufw/user6.rules user6_rules_bak
	cp /lib/ufw/ufw-init ufw-init_bak
	echo "UFW backup created in" $(pwd)
}

# Restores ufw files from backups
restore_ufw() {
	cp default_ufw_bak /etc/default/ufw
	cp user_rules_bak /etc/ufw/user.rules
	cp user6_rules_bak /etc/ufw/user6.rules
	cp ufw-init_bak /lib/ufw/ufw-init
	echo "UFW successfully restored"
}

# This function will enable UFW if not running, and will disable it if running
switch_ufw() {
    if ufw status | grep -q "Status: active"; then
        ufw disable
        echo "UFW is now disabled"
    elif ufw status | grep -q "Status: inactive"; then
        ufw enable
        echo "UFW is now enabled"
    else
        echo "Error"
    fi
}

# Creates a backup of iptables
backup_iptables() {
	iptables-save > iptables_bak
	echo "iptables backup created in" $(pwd)
}

# Restores iptables from a backup
# Ensure that a backup was already created prior to using this
restore_iptables() {
	iptables-restore < iptables_bak
	echo "iptables successfully restored"
}


# Main menu
if [ $EUID != 0 ]; then
    echo "This script must be ran as superuser (use sudo)"
    exit 1
fi

while true; do
    echo "UFW Firewall Rules:"
    ufw status numbered
    if [ $? -ne 0 ]; then
        echo "UFW is not installed. Please install UFW."
        exit 1
    fi
    echo "1. Enable/Disable UFW"
    echo "2. Add Rule"
    echo "3. Remove Rule"
    echo "4. Backup UFW Rules"
	echo "5. Restore UFW Rules"
	echo "6. Backup IPTables Rules"
	echo "7. Restore IPTables Rules"
    echo "8. Exit"
    
    read -p "Select an option (1/2/3/4/5/6/7/8): " choice
    
    case $choice in
        1) switch_ufw;;
        2) add_rule;;
        3) remove_rule;;
        4) backup_ufw;;
		5) restore_ufw;;
		6) backup_iptables;;
		7) restore_iptables;;
        8) exit;;
        *) echo "Invalid option. Please select a valid option.";;
    esac
done
