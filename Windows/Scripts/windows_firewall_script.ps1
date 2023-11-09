# Function to Audit Existing Firewall Rules
function Audit-FirewallRules {
    Get-NetFirewallRule
}

# Function to Backup Firewall Rules
function Backup-FirewallRules {
    Get-NetFirewallRule | Export-CliXML -Path "C:\FirewallRulesBackup.xml"
}

# Function to Restore Firewall Rules from Backup
function Restore-FirewallRules {
    Import-CliXML -Path "C:\FirewallRulesBackup.xml" | ForEach-Object {
        New-NetFirewallRule -Name $_.Name -Action $_.Action -Direction $_.Direction -Enabled $_.Enabled -Profile $_.Profile -Protocol $_.Protocol -Program $_.Program -RemoteAddress $_.RemoteAddress -LocalPort $_.LocalPort -RemotePort $_.RemotePort
    }
}

# Function to Create a New Firewall Rule with User Prompts
function Create-FirewallRule {
    $Name = Read-Host "Enter the name for the new rule"
    $Action = Read-Host "Enter the action (Allow/Deny)"
    $Direction = Read-Host "Enter the direction (Inbound/Outbound)"
    $Enabled = Read-Host "Is the rule enabled? (True/False)"
    $Profile = Read-Host "Enter the profile (Domain/Private/Public/Any)"
    $Protocol = Read-Host "Enter the protocol (TCP/UDP/Any)"
    $Program = Read-Host "Enter the program path (e.g., C:\Path\To\Your\Application.exe)"
    $RemoteAddress = Read-Host "Enter the remote address (e.g., Any/192.168.1.1/SpecificAddress)"
    $LocalPort = Read-Host "Enter the local port (e.g., 80/8080)"
    $RemotePort = Read-Host "Enter the remote port (e.g., Any/80/8080)"

    # Validate and create the firewall rule
    if ($Action -in @("Allow", "Deny") -and
        $Direction -in @("Inbound", "Outbound") -and
        $Enabled -in @("True", "False") -and
        $Profile -in @("Domain", "Private", "Public", "Any") -and
        $Protocol -in @("TCP", "UDP", "Any")) {
        New-NetFirewallRule -Name $Name -Action $Action -Direction $Direction -Enabled [System.Convert]::ToBoolean($Enabled) -Profile $Profile -Protocol $Protocol -Program $Program -RemoteAddress $RemoteAddress -LocalPort $LocalPort -RemotePort $RemotePort
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
        } else {
            Write-Host "Rule removal canceled."
        }
    }
    else {
        Write-Host "Invalid choice. Please enter a valid rule number."
    }
}

# Example Usage
# Audit existing firewall rules
Audit-FirewallRules

# Backup firewall rules
Backup-FirewallRules

# Restore firewall rules from backup
Restore-FirewallRules

# Create a new firewall rule
# Create-FirewallRule

# Remove a firewall rule
# Remove-FirewallRule
