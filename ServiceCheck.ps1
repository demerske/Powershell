$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"
$header = "System`tSophos`tSymantec"
$outfile = "$env:userprofile\desktop\avreport.txt"
Add-Content $header -path $outfile

$list = $find.findall()

ForEach($itm in $list){
	$comp = [string]$itm.properties.name
	$sophos = gwmi win32_service -computer $comp -filter "NAME='SAVService'"
	If($sophos -ne $null){$sophosout = $sophos.state}
	Else{$sophosout = "Not Present"}
	$symsvc = gwmi win32_service -computer $comp -filter "Name='Symantec AntiVirus'"
	if($symsvc -ne $null){$symout = $symsvc.state}
	Else{$symout = "Not Present"}
	$output = $comp + "`t" + $sophosout + "`t" + $symout
	Write-Host $output
	Add-Content $output -path $outfile
}