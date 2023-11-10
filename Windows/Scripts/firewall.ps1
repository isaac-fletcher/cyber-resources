# Function to Audit Existing Firewall Rules
function Audit-FirewallRules {

	Get-NetFirewallRule

}



# Function to Backup Firewall Rules

function Backup-FirewallRules {

	param (
        [string]$JsonPath = "C:\FirewallRules.json"
    )

    # Get all inbound and outbound rules
    $firewallRules = Get-NetFirewallRule | Where-Object { $_.Direction -eq "Inbound" -or $_.Direction -eq "Outbound" }

    # Export the firewall rules to a JSON file
    $firewallRules | ConvertTo-Json | Set-Content -Path $JsonPath

    Write-Host "Firewall rules exported to $CsvPath"

}



# Function to Restore Firewall Rules from Backup

function Restore-FirewallRules {
    param (
        [string]$JsonPath = "C:\FirewallRules.json"
    )

    if (-not (Test-Path $JsonPath -PathType Leaf)) {
        Write-Host "The specified JSON file does not exist: $JsonPath"
        return
    }

    # Import the firewall rules from the JSON file
    $importedRules = Get-Content -Path $JsonPath | ConvertFrom-Json

    # Loop through each imported rule and create it in the Windows Firewall
    foreach ($rule in $importedRules) {
        $DisplayName = $rule.DisplayName
        $Name = $rule.Name
        $Enabled = $rule.Enabled
        $Action = $rule.Action
        $Direction = $rule.Direction
        $Profile = $rule.Profile
        $LocalPort = $rule.LocalPort
        $RemotePort = $rule.RemotePort
        $LocalAddress = $rule.LocalAddress
        $RemoteAddress = $rule.RemoteAddress

        New-NetFirewallRule -DisplayName "$DisplayName" -Name "$Name" -Enabled $Enabled -Action $Action -Direction $Direction -Profile $Profile -LocalPort $LocalPort -RemotePort $RemotePort -LocalAddress $LocalAddress -RemoteAddress $RemoteAddress
    }

    Write-Host "Firewall rules imported from $JsonPath"
}



# Function to Create a New Firewall Rule with User Prompts

function Create-FirewallRule {

	$Name = Read-Host "Enter the name for the new rule"

	$Action = Read-Host "Enter the action (Allow/Block)"

	$Direction = Read-Host "Enter the direction (Inbound/Outbound)"

	$Enabled = Read-Host "Is the rule enabled? (True/False)"

	$Profile = Read-Host "Enter the profile (Domain/Private/Public/Any)"

	$Protocol = Read-Host "Enter the protocol (TCP/UDP/Any)"

	#$RemoteAddress = Read-Host "Enter the remote address (e.g., Any/192.168.1.1/SpecificAddress)"

	$LocalPort = Read-Host "Enter the local port (e.g., 80/8080)"

	
	# Validate and create the firewall rule

	if ($Action -in @("Allow", "Block") -and

		$Direction -in @("Inbound", "Outbound") -and

		$Enabled -in @("True", "False") -and

		$Profile -in @("Domain", "Private", "Public", "Any") -and

		$Protocol -in @("TCP", "UDP", "Any")) {

		New-NetFirewallRule -Name $Name -DisplayName $Name -Action $Action -Direction $Direction -Enabled $Enabled -Profile $Profile -Protocol $Protocol -LocalPort $LocalPort

		Write-Host "Firewall rule created successfully."

	}

	else {

		Write-Host "Invalid input. Please make sure you enter valid values for the parameters."

	}

}



# Function to Remove a Firewall Rule with User Prompt and Confirmation

function Remove-FirewallRule {

	$Rules = Get-NetFirewallRule | Select-Object Name, DisplayName



	if ($Rules.Count -eq 0) {

		Write-Host "No firewall rules found."

		return
	}



	Write-Host "Existing firewall rules:"

	$RuleNumber = 1

	$Rules | ForEach-Object {

		Write-Host "$RuleNumber. $($_.Name) - $($_.DisplayName)"

		$RuleNumber++

	}



	$Choice = Read-Host "Enter the number of the rule to remove"


	if ($Choice -ge 1 -and $Choice -le $Rules.Count) {

		$RuleToRemove = $Rules[$Choice - 1].Name



		$Confirm = Read-Host "Are you sure you want to delete the rule '$RuleToRemove'? (Yes/No)"

		if ($Confirm -eq "Yes" -or $Confirm -eq "yes" -or $Confirm -eq "Y" -or $Confirm -eq "y") {
			Remove-NetFirewallRule -Name $RuleToRemove

			Write-Host "Firewall rule '$RuleToRemove' removed successfully."

		} 
		else {

			Write-Host "Rule removal canceled."

		}

	}

	else {

		Write-Host "Invalid choice. Please enter a valid rule number."

	}

}



# Example Usage

# Audit existing firewall rules
#Audit-FirewallRules



# Backup firewall rules
#Backup-FirewallRules



# Restore firewall rules from backup
#Restore-FirewallRules



# Create a new firewall rule
#Create-FirewallRule



# Remove a firewall rule
#Remove-FirewallRule