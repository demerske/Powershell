$find = new-object system.directoryservices.directorysearcher
$find2 = new-object system.directoryservices.directorysearcher
ri "$env:userprofile\desktop\temp\*.*" -force
ri "$env:userprofile\desktop\groupstate2.txt"
$sroots = @(#Array of LDAP connections to search)
$header = "Team`tUsers`tPermissions`tMigration`tUsercount`tManagers"
Add-Content $header -path "$env:userprofile\desktop\groupstate2.txt"

ForEach($sroot in $sroots){
	$find.searchroot = $sroot
	$find.filter = "(objectcategory=group)"
	$list = $find.findall()
	ForEach($itm in $list){
		$name = [string]$itm.properties.name
		$member = [string]$itm.properties.member
		$memberof = [string]$itm.properties.memberof
		If($member -ne ""){$mem = "Migrated"}
		Else{$mem = "Pending"}
		If($memberof -ne ""){$memof = "Staged"}
		Else{$memof = "Pending"}
		If(($mem -eq "Migrated") -and ($memof -eq "Staged")){$state = "Completed"}
		Else{$state = "Pending"}
		$find2.filter = "(&(objectcategory=user)(extensionattribute12=$name))"
		$users = $find2.findall()
		$count = $users.count
		ForEach($user in $users){
			$mgr = [string]$user.properties.manager
			$mgr = ([adsi]"LDAP://$mgr").name
			Add-Content $mgr -path "$env:userprofile\desktop\temp\$name.txt"
		}
		
		$mgrs = get-content "$env:userprofile\desktop\temp\$name.txt"
		$mgrs = $mgrs | Select -unique
		$mgrs = [system.string]::Join("; ",$mgrs)
		
		$output = $name + "`t" + $mem + "`t" + $memof + "`t" + $state + "`t" + $count + "`t" + $mgrs
		Write-Host $output
		Add-Content $output -path "$env:userprofile\desktop\groupstate2.txt"
	}
}