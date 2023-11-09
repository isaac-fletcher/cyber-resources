#!/bin/bash

# Declares command line args   
OPTION="$1"
FW_CHOICE="$2"
DIR="$3"

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

restore_backup() {
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


main()
{
    result=$(sudo ufw status)
    if [ "${result}" = "Status: active\n" ]; then
        echo "ufw not enabled (have you run \"sudo ufw enable?\")"
        exit 1
    fi

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

    echo "Program has finished"
} 

main