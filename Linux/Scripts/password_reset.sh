#!/bin/bash

# Declares user file and maximum password length
USER_FILE="$1"
PASSWD_LEN=14

make_password()
{
    # Declares characters for password 
    passwd_chars="A-Za-z0-9!@#$%^&*()+-_=[]{}:;,.<>?"
    local password=$(tr -cd "$passwd_chars" < /dev/urandom | head -c "$PASSWD_LEN")
    echo "$password"
}

reset_password()
{
    # Resets password to something random
    local user="$1"
    random_password=$(make_password)
    echo "Resetting password for $user to: $random_password"
}

main()
{
    # Reads from the file and reset's each user
    while IFS= read -r user; do
        reset_password "$user"
    done < "$USER_FILE" 

    echo "Password reset for all specified users"
}

main