$outputpath = Read-Host "Enter path to output file"
$search = new-object system.directoryservices.directorysearcher
$search.filter = "(operatingsystem=*Server*)" #"(&(&(&(samAccountType=805306369)(!(primaryGroupId=516)))(objectCategory=computer)(operatingSystem=Windows Server*)))"
$Systems = $search.findall()

foreach($system in $systems){
	$system = [string]$system.Properties.name
	$comp = gwmi Win32_bios -computername $system
	$sn = $comp.serialnumber
	$make = $comp.manufacterer
	$model = $comp.version
	if($error[0].exception -ne $null){
		$output = $system + "`t" + $error[0].exception.message.tostring()
		$error.clear()
	}
	ElseIf($error[0].exception -eq $null){
		$output = $system + "`t" + $SN + "`t" + "$make $model"
	}
	Write-Host $output
	Add-Content $output -path $outputpath
}