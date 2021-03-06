$find = new-object system.directoryservices.directorysearcher

$team = Read-Host "Enter name of team to add user to (I.E. TM_nonelevatedteam or ADM_elevatedteam)"

$teamd = $team.replace("TM_","TMD_")
$prefix = "\\shareserver\useraccessreview2011\_HistoricalUserAccess"
$exempt = get-content "$env:userprofile\desktop\exemptgroups.txt"

$find.filter = "(&(objectcategory=user)(extensionattribute12=$team))"
$users = $find.findall()

ForEach($user in $users){
	$uname = [string]$user.properties.samaccountname
	$usrname = [string]$user.properties.name
	Add-Content $usrname -path "\\shareserver\useraccessreview2011\_UsersMigrated\Migration\$team.txt"
	$udn = [string]$user.properties.distinguishedname
	$umemberof = $user.properties.memberof
	$outfile = "$prefix\uname.txt"
	if((Test-Path $outfile) -eq $true){Write-Host "User $uname already migrated."}
	Else{
		ForEach($umem in $umemberof){
			If($exempt -notcontains $umem){
				Add-Content $umem -path "$prefix\$uname.txt"
				$group = [adsi]"LDAP://$umem"
				$group.member.remove($udn)
				$group.setinfo()
			}
		}

		$find.filter = "(&(objectcategory=group)(name=$team))"
		$adteam = $find.findone()
		$adteam = [adsi]$adteam.path
		$adteam.member.add($udn)
		$adteam.setinfo()
		
		$find.filter = "(&(objectcategory=group)(name=$teamd))"
		$adteam = $find.findone()
		$adteam = [adsi]$adteam.path
		$adteam.member.add($udn)
		$adteam.setinfo()
		Write-Host $uname, "Complete"
	}
}