$find = new-object system.directoryservices.directorysearcher
$get = get-content "$env:userprofile\desktop\list.txt"



ForEach($a in $get){
	$find.filter = "(&(objectcategory=user)(extensionattribute12=$a))"
	$users = $find.findall()
	$find.filter = "(&(objectcategory=group)(name=$a))"
	$group = $find.findone()
	$group = [adsi]$group.path
	ForEach($user in $users){
		Write-Host $user.properties.name
		$mgr = [string]$user.properties.manager
		$mgr2 = [adsi]"LDAP://$mgr"
		$mgr2 = [string]$mgr2.name
		$mgr2 = $mgr2.replace(","," ")
		Add-Content $mgr2 -path "$env:userprofile\desktop\temp\$a.txt"
		$group.managedby = $mgr
		$group.setinfo()
	}
	$mgrs = get-content "$env:userprofile\desktop\temp\$a.txt"
	$mgrs = $mgrs | Select -unique
	$mgrs = [system.string]::Join(", ",$mgrs)
	$output = $a + "`t" + $mgrs
	Add-Content $output -path "$env:userprofile\desktop\readygroupinfo.txt"
}