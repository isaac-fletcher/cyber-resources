
$path = Read-Host "Enter a csv to read from"

Import-Csv $path | Foreach-Object {
	$params = @{
		Name = $_.Name
		Pssword = ConvertTo-SecureString $_.Password -AsPlainText -Force
		FullName = $_.FullName
	}

	New-LocalUser @params

}
