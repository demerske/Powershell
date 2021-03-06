$search = new-object system.directoryservices.directorysearcher
$search.filter = "(&(&(&(samAccountType=805306369)(!(primaryGroupId=516)))(objectCategory=computer)(operatingSystem=Windows Server*)))"
$systems = $search.findall()
ForEach($system in $systems){
	$system = [string]$system.Properties.name
	$list = ([adsi] "WinNT://$system").psbase.children | ?{$_.SchemaClassName -match "user"}
	ForEach($itm in $list){
		if($itm.properties.name -eq "installadmin"){
			([adsi] "WinNT://$system").psbase.children.remove("WinNT://$system" + "/" + $itm.properties.name)
		}
	}
}
