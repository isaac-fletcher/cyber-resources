#!/bin/bash

# Don't run if not root
if [ "$EUID" -ne 0 ]
  then echo "Please run this script as root"
  exit
fi

# Function to search for strings in a list 
exists_in_list () {
	LIST=$1
	DELIMETER=$2
	WORD=$3
	[[ "$LIST" =~ ($DELIMETER|^)$WORD($DELIMETER|$) ]]
}

# To use, call would look like $(getChoice minumum_value maximum_value)
# Returns choice value to stdout
getChoice () {
	local temp
	while : ;
	do
		read -p 'Enter your choice: ' temp
		[[ $temp < $1 || $temp > $2 ]] || break
	done
	echo $temp
}

# Get names of only users that can login to system
excludeNoLoginUsers () {
	echo "Getting only the system accounts that can be logged into..."
	grep -v "nologin" /etc/passwd | awk -F':' '{ print $1 }' > userAccounts.txt
}

# Get names of all users
auditUsers () {
	echo "Getting all system accounts..."
	awk -F':' '{ print $1 }' /etc/passwd > userAccounts.txt
}

# Get names of all groups
getGroups () {
	echo "Getting groups..."
	cat /etc/group | awk -F':' '{ print $1 }' > groups.txt
}

# Get groups and the users that are a part of them
getUsersWithGroups () {
	echo "Getting groups and the users that are a part of them..."
	cat /etc/group | awk -F':' \
	'{  \
		if ( $4 != "") { \
			print $1":"; print $4; print "" \
		} \
	}' > groupsAndUsers.txt
}

getKnownUsers () {
	users=$(awk -F':' '{ print $1 }' /etc/passwd)
	set - $users
}

generatePasswd () {
	echo "$(tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c $1; echo)"
}

randomizePasswd () {
	# Don't reset passwords for invalid users
	if ! exists_in_list "$users" "" $1
	then
		echo "$1 not a valid user"
		return 
	fi

	echo "Randomizing $1's password..."
	local newPasswd="$(generatePasswd $2)"
	echo "$1:$newPasswd" | sudo chpasswd -c SHA512
	echo "$1 new password: $newPasswd"
}

createAccount () {
	# Get name for account
	read -p 'Enter a name for the new account: ' name

	# Don't create an account that already exists
	if exists_in_list "$users" "" $name
	then
		echo "$name is already a user"
		return
	fi

	# Create account with home directory and randomly generated password
	local newPasswd="$(generatePasswd 20)"
	useradd -p $(openssl passwd -6 $newPasswd) $name
	echo "Added $name to users with password: $newPasswd"

	# Update known users
	getKnownUsers
}

deleteAccounts () {
	echo "Enter usernames of accounts to delete. Enter DONE when you are done deleting accounts"
	while : ;
	do
		# Get name of account to delete
		read -p 'Name of account to delete: ' accountName

		[[ $accountName != "DONE" ]] || break

		if ! exists_in_list "$users" "" $accountName
		then
			echo "$accountName is not a valid account name"
			echo
			continue
		fi

		# Delete account 
		userdel -f $accountName
		echo "Successfully deleted the account $accountName"
		echo

		# Update known users
		getKnownUsers

	done
}

disableAccounts () {
	echo "Enter usernames of accounts to disable. Enter DONE when you are done disabling accounts"
	while : ;
	do
		# Get name of account to disable
		read -p 'Name of account to disable: ' accountName

		[[ $accountName != "DONE" ]] || break

		if ! exists_in_list "$users" "" $accountName
		then
			echo "$accountName is not a valid account name"
			echo
			continue
		fi

		# Delete account 
		usermod -L -e 1 $accountName
		echo "Successfully disabled the account $accountName"
		echo

	done
}


# ===============================================================


# Get a list of all known users
getKnownUsers

# Get input
echo "Please enter one of the following numbers:"
echo "1) Audit system accounts and groups"
echo "2) Randomize an account's password"
echo "3) Create, delete, or disable an account"

# Get a valid choice number
choice="$(getChoice 1 3)"

# Audit the system
if [[ $choice -eq 1 ]]
then
	# Get choice of which users to get
	echo
	echo "Please enter whether to audit user accounts that..."
	echo "1) Can only be logged into"
	echo "2) All user accounts"

	userAccChoice="$(getChoice 1 2)"

	# Get specified users
	if [[ $userAccChoice -eq 1 ]]
	then
		excludeNoLoginUsers
	else
		auditUsers
	fi

	# Get names of all groups
	getGroups

	# Get groups that have at least one user
	getUsersWithGroups

elif [[ $choice -eq 2 ]]
then
	# Get a length for new passwords to be
	echo
	echo "Please enter a length for new passwords to be:"
	while : ;
	do
		read -p 'Length: ' passwdLength
		[[ $passwdLength < 1 ]] || break
	done

	# Get usernames to reset passwords for... continue looping and resetting passwords until DONE passed in
	echo
	echo "Please enter the names of users that you want to reset passwords for."
	echo "Enter DONE when you are finished:"
	echo
	while : ;
	do
		read -p 'Username: ' username
		[[ $username != "DONE" ]] || break
		# Randomize password for username
		randomizePasswd $username $passwdLength
		echo
	done
else
	while : ;
	do
		echo
		echo "Please choose to either:"
		echo "0) Stop"
		echo "1) Create a new account"
		echo "2) Delete accounts"
		echo "3) Disable accounts"

		modAccChoice="$(getChoice 0 3)"
		echo

		if [[ $modAccChoice -eq 1 ]]
		then
			createAccount
		elif [[ $modAccChoice -eq 2 ]]
		then
			deleteAccounts
		elif [[ $modAccChoice -eq 3 ]]
		then
			disableAccounts
		else
			break
		fi
	done
fi
