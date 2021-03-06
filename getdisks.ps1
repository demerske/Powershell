$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"

$list = $find.findall()

ForEach($itm in $list){
	$name = [string]$itm.properties.name
	$drives = gwmi -query "Select DeviceID from Win32_logicaldisk Where Drivetype=3" -computer $name
	$drives = $drives | Select DeviceID
	If($drives.count -le 1){$drives = $drives.deviceID}
	Else{$drives = [string]::Join(" ",$drives).replace("@{DeviceID=","").replace("}","")}
	$output = $name + "`t" + $drives
	Write-Host $output
	Add-Content $output -path "$env:userprofile\desktop\ServerDrives.txt"
}