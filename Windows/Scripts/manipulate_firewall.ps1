#PARAMETERS ARE NOT CASE-SENSITIVE
#C is for Create
#R is for Remove
<#Param(
    [Parameter(Mandatory)]
    [ValidateSet("C", "R")]
    $Type
)

function Create-Rule {
    Write-Host "`nEnter name of rule: "
    $name = Read-Host

    Write-Host "`nWhat will your rule do?: "
    $des = Read-Host

    Write-Host "`nWhat direction will traffic come from? (In/Out): "
    $dir = Read-Host

    Write-Host "`nWill this rule set a blanket rule for a network type? (Only traffic from same subnet, etc.), (T/F): "
    $isBlanket = Read-Host

    Write-Host "`nBlock or Allow traffic (Block, Allow, N/A for blank or unneeded): "
    $traffic = Read-Host

    Write-Host "`nWill a program be used with this rule? (T/F): "
    $isProgram = Read-Host

    #Sets $dir (direction of traffic) to
    #a valid input regardless of user input
    if($dir -eq "in"){
        $dir = "Inbound"
    } else {}
        $dir = "Outbound"
    }

    if($isBlanket -eq "T"){
        Write-Host "`n
        `nThis part is very sensitive, options are Windows Keywords (Any, LocalSubnet, etc.), single or range of IP addresses 
        `nEnter the type of network this rule will apply to: "
        
        $net = Read-Host
    } else {
        Write-Host "Will this rule affect a "
    }


    $params = @{
        DisplayName = $name
        Description = $des
        Direction = $dir
        if($traffic -ne "N/A"){
            Action = $traffic
        }

    }

}

function Remove-Rule {

}

if($Type -eq "C"){
    Create-Rule
}

if($Type -eq "R"){
    Remove-Rule
}
}

#>

<#
The above is a half-finished skeleton code.
The issue with the a script that will create new
rules is beyond my skill, as well as not worth it.
The amount of input needed to determine the create command
takes more time than refering to the documentation. So,
I made a script that prints out useful documentation instead.

I will keep the above code just for reference or improvement in the future
#>

function NewRule {  
    Write-Host "`n`n"
    Write-Host "New-NetFirewall Rule creates new rules for the firewall (duh)"
    Write-Host "Here is a list of parameters that you should memorize:"
    Write-Host "`t-Allow or -Block : Does as name implies, blocks/allows traffic. If this is not used, default will be Allow"
    Write-Host "`t-All : will return all firewall rules within specified POLICY STORE (see -PolicyStore)"
    Write-Host "`t-AssociatedNetFirewallProfile : returns rules associted with a given firewall profile"
    Write-Host "`t`Description : returns firewall rules with matching description"
    Write-Host "`t-Direction : specifies direction of firewall rules (Inbound or Outbound), default is Outbound"
    Write-Host "`t-DisplayName : returns firewall rule names that match input"
    Write-Host "`t-Enabled : returns if rule is enabled (True, yes | false, no)"
    Write-Host "`t-PolicyStore : returns the container for firewall and IPsec policy (Options are: PersistentStore, ActiveStore, RSOP, read more on Windows Documentation)"
    Write-Host "`t-Status : specifies firewall rules that match the status"
    Write-Host "`tFor more options and more depth, see https://learn.microsoft.com/en-us/powershell/module/netsecurity/get-netfirewallrule?view=windowsserver2022-ps"
}

function RemoveRule {
    Write-Host "Not implemented"
}

function GetRule {
    Write-Host "Not implemented"
}

function SetRule {
    Write-Host "Not implemented"
}

function RestoreRule {
    Write-Host "Here are steps for restore/backup: "
    Write-Host "`tFirst, install Firewall Managaer, run this command: "
    Write-Host "`t`tInstall-Module -Inbound -Name Firewall-Manager"
    Write-Host "`tFor export: Export-FirewallRules -Inbound -Name Dropbox -CSVFile C:\"
    Write-Host "`t`tChange name to your desired filename, and destination at end"
    Write-Host "`tExport multiple rules: Export-FirewallRules -Inbound -Name '*' -CSVFile C:\"
    Write-Host "`t`tFor -Name, the * will be ALL rules, but you can do -Name 'Microsoft*' (Replace ' with quotes)"
    Write-Host "`tImport: Import-FirewallRules -CSVFile C:"
    Write-Host "`t`tUse the file you exported for destination"
}

Write-Host "Welcome! This script contains easy-to-find documentation for Firewall Rules in Powershell!"
Write-Host "`nThe commands are listed in the following order: Create Rule, Remove Rule, See Rule, Change Rule, and Backup/Restore Rule!"
Write-Host "`nList of the commands:"
Write-Host "`nNew-NetFirewallRule (N)`nRemove-NetFirewallRule (R)`nGet-FirewallRule (G)`nSet-FirewallRule (S)`nExport/Import Firewall Rules (E)"
Write-Host "`nWhich command would you like to see documentation for? (enter letter following command name): "

$choice = Read-Host

switch ($choice){
    N {NewRule; Break}
    R {RemoveRule; Break}
    G {GetRule; Break}
    S {SetRule; Break}
    E {RestoreRule; Break}
}
