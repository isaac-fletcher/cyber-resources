#!/bin/bash

# Declares command line args   
OPTION="$1"
FW_CHOICE="$2"
DIR="$3"

# This function audits the current iptable and ufw rules
audit_rules()
{
    # Audits rules to firewall_rules.txt
    echo "Auditing firewall rules to firewall_rules.txt..."
    echo "Iptable rules:" > firewall_rules.txt
    sudo iptables -L -n >> firewall_rules.txt

    echo "\nIp6table rules:"
    sudo ip6tables -L -n >> firewall_rules.txt
    
    echo "\nUFW firewall rules:"
    sudo ufw status verbose >> firewall_rules.txt

    return $?
}

# Creates a backup of current firewall rules
create_backup()
{
    if [ "${FW_CHOICE}" = "ufw" ]; then
        for file in /etc/ufw/; do
            filename=$(basename "$file")
            
            backup_filename="${filename%.*}_etc_backup.rules"
            
            # Copy the file to the backup directory
            sudo cp -r "$file" "$backup_dir$backup_filename"
            
            echo "Backed up $file to $backup_dir$backup_filename"
        done

        for file in /lib/ufw/; do
            filename=$(basename "$file")
            
            backup_filename="${filename%.*}_lib_backup.rules"
            
            # Copy the file to the backup directory
            sudo cp -r "$file" "$backup_dir$backup_filename"
            
            echo "Backed up $file to $backup_dir$backup_filename"
        done
    
    elif [ "${FW_CHOICE}" = "iptables" ]; then
        sudo iptables-save > "$FILE/iptables_backup.rules" 
    else 
        echo "Please enter ufw or iptable rules to back up"
        exit 1
    fi
    return $?
}

# Restores rules from a directory passed in
restore_backup() 
{
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
    return $?
}

# Creates a new firewall rule from the user
create_rule()
{
    echo "ufw, iptable, or a rule for both?"
    read USER_CHOICE

    case $USER_CHOICE in
    ufw) 
    echo "Enter the rule you want to create: "
    read USER_RULE
    result=$(USER_RULE)
    ;;
    iptable)
    ;;
    *)
    echo "Please enter a legitimate choice"

    return result
}

# Deletes a firewall (if it exists) from the user
delete_rule()
{
    echo "Delete a ufw rule, iptable rule, or both?"
    read USER_CHOICE

    case $USER_CHOICE in
    ufw)
    echo "Enter the rule you want deleted: "
    read USER_CHOICE
    result=$(USER_CHOICE)
    ;;
    iptable)
    echo "Enter the rule you want deleted: "
    read USER_CHOICE
    result=$(USER_CHOICE)
    ;;
    *)
    echo "Please enter a legitimate choice"

    return return
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
        echo "4) Create a new firewall rule"
        echo "5) Delete an existing firewall rule"
        echo "6) Type quit to quit"
        read USER_CHOICE

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
        create_rule
        ;;
        5)
        delete_rule
        ;;
        6)
        END_VAR=true
        ;;
        *)
        echo "Improper usage, please "
        ;;
        esac
    done

    if [ "${OPTION}" = "backup" ]; then
        echo "Backing up current rules..."
        create_backup
        if [ "$?" -eq 0 ]; then
            echo "Backup completed"
        else
            echo "Backup failed"
        fi
    elif [ "${OPTION}" = "restore" ]; then
        echo "Restoring to previous backup..."
        restore_backup
        if [ "$?" -eq 0 ]; then
            echo "Backup restored"
        else
            echo "Restoration failed"
        fi
    else
        echo "Improper usage (please run in "./firewall_backup.sh \<backup/restore\> \<ufw or iptables\> \<directory storing backups\>" format)"
        exit 1
    fi
} 

main