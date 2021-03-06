$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server 2008*))"

$list = $find.findall()

ForEach($itm in $list){
	$comp = [string]$itm.properties.name
	$nics = gwmi win32_networkadapter -computer $comp -filter "AdapterTypeID=0"

	ForEach($nic in $nics){
		$nic = gwmi -class MSPower_DeviceEnable -namespace root\WMI -computer $comp | ?{$_.InstanceName.ToUpper().Startswith($nic.PNPDeviceID.ToUpper())}
		if($nic.enable -eq $true){
			$nic.enable = $false
			$nic.put()
		}
	}
}