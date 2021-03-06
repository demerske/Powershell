$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 100000
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"

$list = $find.findall()
$error.clear()

ForEach($itm in $list){
	$comp = [string]$itm.properties.name
	$svc = gwmi win32_service -filter "Name='SAVService'" -computer $comp
	if($error[0] -ne $null){$output = $comp + "`t" + $error[0].exception.message.tostring()
		$error.clear()
	}
	Else{$output = $comp + "`t" + $svc.startmode + "`t" + $svc.state}
	Write-Host $output
	Add-Content $output -path "$env:userprofile\desktop\sophosAVState.txt"
}