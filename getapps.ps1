$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"
$outfile = "$env:userprofile\desktop\symantecinstalls.txt"

$list = $find.findall()

ForEach($itm in $list){
	$itm = [string]$itm.properties.name
	$apps = gwmi Win32_service -computer $itm
	If($error[0].exception -ne $null){
		$output = $itm + "`t" + $error[0].exception.message.tostring()
		Add-Content $output -path $outfile
		$error.clear()
	}
	Else{
		$av = "Not Installed"
		$bkp = "Not Installed"
		foreach($app in $apps){
			If($app.name -eq "Symantec AntiVirus"){$AV = "Installed"}
			$output = $itm + "`t" + $AV
		}
		Write-Host $output
		Add-Content $output -path $outfile
	}
}