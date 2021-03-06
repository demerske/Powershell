$find = new-object system.directoryservices.directorysearcher
$sroots = @(#LDAP connection strings to search#)
$find.filter = "(objectcategory=user)"

ForEach($sroot in $sroots){
	$find.searchroot = $sroot

	$list = $find.findall()

	ForEach($itm in $list){
		$loc = [string]$itm.properties.physicaldeliveryofficename
		Write-Host $loc
		Add-Content $loc -path "$env:userprofile\desktop\locations.txt"
	}
}

$locs = get-content "$env:userprofile\desktop\locations.txt"
$locs = $locs | select -unique
ri "$env:userprofile\desktop\locations.txt"
Add-Content $locs -path "$env:userprofile\desktop\locations.txt"