$find = new-object system.directoryservices.directorysearcher
$find.searchroot = $null
$team = Read-Host "Enter Team"
$find.filter = "(&(objectcategory=group)(name=$team))"
$out = "$env:userprofile\desktop\$team.txt"
ri $out

$grp = $find.findone()
$grp = [adsi]$grp.path

$members = $grp.member
$memof = $grp.memberof

Add-Content "Members" -path $out
ForEach($itm in $members){
	$itm = [adsi]"LDAP://$itm"
	Write-Host $itm.name
	Add-Content $itm.name -path $out
}

Add-Content "Name`tDescription" -path $out
ForEach($a in $memof){
	$a = [adsi]"LDAP://$a"
	$name = [string]$a.name
	$desc = [string]$a.description
	$output = $name + "`t" + $desc
	Write-Host $output
	Add-Content $output -path $out
}