$find = new-object system.directoryservices.directorysearcher
$find.searchroot = "LDAP://OU=User Accounts,DC=yourdomain,DC=com"
$find.filter = "(objectcategory=user)"

$list = $find.findall()

ForEach($itm in $list){
	$mgr = [string]$itm.properties.manager
	Add-Content $mgr -path "$env:userprofile\desktop\mgrmaster.txt"
}

$list = get-content "$env:userprofile\desktop\mgrmaster.txt"
$list = $list | Select -unique

ForEach($itm in $list){
	$mgr = [adsi]"LDAP://$itm"
	$name = $mgr.name
	$mname = $mgr.samaccountname
	Write-Host $mname
	$find.filter = "(&(objectcategory=user)(manager=$itm))"
	$reports = $find.findall()
	ForEach($report in $reports){
		$team = [string]$report.properties.extensionattribute12
		Add-Content $team -path "$env:userprofile\desktop\temp\$mname.txt"
	}
	$data = get-content "$env:userprofile\desktop\temp\$mname.txt"
	ri "$env:userprofile\desktop\temp\$mname.txt"
	$data = $data | Select -unique
	$teams = [system.string]::Join("; ",$data)
	$output = [string]$name + "`t" + $teams
	Write-Host $output
	Add-Content $output -path "$env:userprofile\desktop\mgrtoteams.txt"
}