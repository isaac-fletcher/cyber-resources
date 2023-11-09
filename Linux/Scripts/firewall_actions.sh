#!/bin/bash

# This function audits the current iptable and ufw rules
audit_rules()
{
    # Audits rules to firewall_rules.txt
    echo "Auditing firewall rules to firewall_rules.txt..."
    echo "Iptable rules:" > firewall_rules.txt
    sudo iptables -L -n >> firewall_rules.txt

    printf "\nIp6table rules:\n" >> firewall_rules.txt
    sudo ip6tables -L -n >> firewall_rules.txt
    
    printf "\nUFW firewall rules:\n" >> firewall_rules.txt
    sudo ufw status verbose >> firewall_rules.txt

    sudo iptables -L -n
    sudo ip6tables -L -n
    sudo ufw status verbose

    return $?
}

# Creates a backup of current firewall rules
create_backup()
{
    echo "Do you want to back up the ufw rules or iptable rules (enter ufw/iptable)?"
    read -r FW_CHOICE

    echo "echo "Backing up current rules...""

    if [ "${FW_CHOICE}" = "ufw" ]; then
        for file in /etc/ufw/; do
            filename=$(basename "$file")
            
            backup_filename="${filename%.*}_etc_backup_rules"
            
            # Copy the file to the backup directory
            sudo cp -r "$file" "$backup_dir$backup_filename"
            
            echo "Backed up $file to $backup_dir$backup_filename"
        done

        for file in /lib/ufw/; do
            filename=$(basename "$file")
            
            backup_filename="${filename%.*}_lib_backup_rules"
            
            # Copy the file to the backup directory
            sudo cp -r "$file" "$backup_dir$backup_filename"
            
            echo "Backed up $file to $backup_dir$backup_filename"
        done
    
    elif [ "${FW_CHOICE}" = "iptables" ]; then
        sudo iptables-save > "/iptables_backup_rules" 
    else 
        echo "Please enter ufw or iptable rules to back up"
        exit 1
    fi

    echo "Backup created"
    return $?
}

# Restores rules from a directory passed in
restore_backup() 
{
    echo "Backup ufw or iptables firewall rules? (ufw/iptables)"
    read -r FW_CHOICE

    echo "Where are the backups located?"
    read -r DIR

    echo "Restoring to previous backup..."

    # Restore UFW rules from a backup file
    if [ "${FW_CHOICE}" = "ufw" ]; then
        backup_dir="${DIR}/ufw_etc_backup.rules"
        if [ -d "$backup_dir" ]; then
            for item in "$backup_dir"/*; do
                if [ -e "$item" ]; then
                    original_filename=$(basename "$item")
                    if [ -f "$item" ]; then
                        sudo cp -r "$item" "/etc/ufw/$original_filename"
                        echo "Restored $item to /etc/ufw/$original_filename"
                    elif [ -d "$item" ]; then
                        sudo cp -r "$item" "/etc/ufw/"
                        echo "Restored directory $item and its contents to /etc/ufw/"
                    fi
                fi
            done
        fi

        backup_dir="${DIR}/ufw_lib_backup.rules"
        if [ -d "$backup_dir" ]; then
            for item in "$backup_dir"/*; do
                if [ -e "$item" ]; then
                    original_filename=$(basename "$item")
                    if [ -f "$item" ]; then
                        sudo cp -r "$item" "/lib/ufw/$original_filename"
                        echo "Restored $item to /lib/ufw/$original_filename"
                    elif [ -d "$item" ]; then
                        sudo cp -r "$item" "/lib/ufw/"
                        echo "Restored directory $item and its contents to /lib/ufw/"
                    fi
                fi
            done
        fi
    elif [ "${FW_CHOICE}" = "iptables" ]; then
        for backup_file in $(find "${DIR}" -name "iptables_backup_*.rules"); do
            sudo iptables-restore < "$backup_file"
            echo "Restored iptables rules from $backup_file"
        done
    else 
        echo "Please choose to restore ufw or iptable rules"
        exit 1
    fi

    echo "Backup restored"
    return $?
}

main()
{
    result=$(sudo ufw status)
    if [ "${result}" = "Status: active\n" ]; then
        echo "ufw not enabled (have you run \"sudo ufw enable?\")"
        exit 1
    fi

    END_VAR=false

    while [ "$END_VAR" = false ]
    do
        echo "Please choose an action from the menu: "
        echo "1) Audit current firewall rules"
        echo "2) Backup current firewall rules"
        echo "3) Restore firewalls to last backup"
        echo "4) Quit"
        read -r USER_CHOICE

        case $USER_CHOICE in
        1)
        audit_rules
        ;;
        2)
        create_backup
        ;;
        3)
        restore_backup
        ;;
        4)
        END_VAR=true
        ;;
        *)
        echo "Improper usage, please refer to the menu"
        ;;
        esac
    done
} 

main
