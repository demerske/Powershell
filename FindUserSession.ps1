$erroractionpreference = "SilentlyContinue"
$error.clear()

$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=computer)(!operatingsystem=*Server*))"
$tuser = Read-Host "Enter username to find"

$list = $find.findall()

ForEach($itm in $list){
	$comp = [string]$itm.properties.name
	$users = gwmi Win32_LoggedOnUser -computer $comp
	If($error[0] -eq $null){
		Write-Host $comp
		ForEach($user in $users){
			If($user.antecedent.contains($tuser) -eq $true){
				Write-Host "Found $tuser on $comp"
			}
		}
	}
	Else{$error.clear()}
}