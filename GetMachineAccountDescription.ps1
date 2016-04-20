$search = new-object system.directoryservices.directorysearcher
$search.filter = "(objectcategory=computer)"
$scanlist = $search.findall()

ForEach($a in $scanlist){
	$system = [string]$a.Properties.distinguishedname
	$object = [adsi] "LDAP://$system"
	if($object.Name.tostring().tolower().Contains("prd")){
		Write-Host $object.Name, $object.description
	}
}