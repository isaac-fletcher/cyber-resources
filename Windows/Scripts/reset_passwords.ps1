# Author: Tim Koehler
# Script for resetting users' passwords. Users are provided in a CSV file, and results are saved to an output file.

$file_path = Read-Host "Please enter the name of the .csv file containing the users who need their password reset"
# Name of file containing new passwords. Change as needed.
$output_file = "new_passwords.txt"

# Open the csv file provided by the user. Exit with an error if the file fails to open.
try {
    $users_file = Import-CSV -Path .\$file_path -Header "Username"
} catch {
    "Cannot open the file $file_path."
    "Ensure that the file exists and is provided in the following format (each user must be on a new line:"
    "user1"
    "user2"
    "..."
    return
}

$users_file | ForEach-Object {
        # Read the current username from the CSV
        $user_name = $_.Username
        echo "Resetting password for $user_name..."
        
        # Generate a random password composed of lower and uppercase letters and special characters
        $new_password = 
            -join (([char]'a'..[char]'z' + [char]'A'..[char]'Z' + [char]"!" + [char]"#"..[char]"-" + [char]"?"..[char]"@") | Get-Random -Count 20 | % {[char]$_})
        # Reset password
        net user $user_name $new_password

        # Save the data to the output file
        Add-Content -Path .\$output_file -Value "$user_name::$new_password"
}

# Display the path to the output file.
$output_path = (Get-ChildItem .\$output_file -Recurse).fullname
echo "Passwords were successfully reset and saved to $output_path."