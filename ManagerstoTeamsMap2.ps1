$find = new-object system.directoryservices.directorysearcher
$find2 = new-object system.directoryservices.directorysearcher
$find.searchroot = "LDAP://OU=Security,OU=Groups,DC=yourdomain,DC=com"
$find.filter = "(objectcategory=group)"

$outfile = "c:\scripting\output\mgrtogrouplist.txt"
ri $outfile
Add-Content "Manager`tTeam" -path $outfile

$teams = $find.findall()

ForEach($team in $teams){
	$name = [string]$team.properties.name
	$members = $team.properties.member
	ForEach($mem in $members){
		$mem = [adsi]"LDAP://$mem"
		$mgr = $mem.manager
		$mgr = ([adsi]"LDAP://$mgr").name
		$output = [string]$mgr + "`t" + $name
		Add-Content $output -path $outfile
	}
}

$list = get-content $outfile
ri $outfile
$list = $list | Select -unique
Write-Host $list
Add-content $list -path $outfile