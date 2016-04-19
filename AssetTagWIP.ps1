$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"

$list = $find.findall()

foreach($itm in $list){
	$comp = [string]$itm.properties.name
	$at = gwmi win32_bios -computer $comp
	if($at.version.contains("DELL")){
		write-host $comp, $at.serialnumber
	}
}