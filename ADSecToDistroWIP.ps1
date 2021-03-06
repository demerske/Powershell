$find = new-object system.directoryservices.directorysearcher
$find.filter = "(objectcategory=group)"
$find.searchroot = "LDAP://OU=Teams,OU=Security,OU=Groups,DC=yourdomain,DC=com"

$prefix = "CN="
$postsec = ",OU=Teams,OU=Security,OU=Groups,DC=yourdomain,DC=com"
$postdis = ",OU=Distribution,OU=Groups,DC=yourdomain,DC=com"


$list = $find.findall()

$root = [adsi]"LDAP://OU=Distribution,OU=Groups,DC=yourdomain,DC=com"
$find.searchroot = $null

ForEach($itm in $list){
	$team = [string]$itm.properties.name
	$distro = $team.replace("TM_","TMD_")
	$distro = $prefix + $distro + $postdis
	$team = [adsi]$itm.path
	$member = $team.memberof
	ForEach($mem in $member){
		$mem = [adsi]"LDAP://$mem"
		If($mem.grouptype -eq 8){
			$mems = $mem.member
			$mem.member = $mems + $distro
			$mem.setinfo()
			Write-Host $mem.name
		}
	}
}

$team = $prefix + $team + $postsec
$distro = $prefix + $distro + $postdis
$team = [adsi]"LDAP://$team"
$distro = [adsi]"LDAP://$distro"
$teammem = $team.member
$distro.member = $teammem
$distro.setinfo()
}









$find.filter = "(&(objectcategory=group)(name=$distro))"
$test = $find.findall()
If($test.count -eq 0){
$ngroup = $root.create("group","CN=" + $distro)
$ngroup.put("samaccountname",$distro)
$ngroup.setinfo()
Write-Host "$distro Created"
$find.filter = "(&(objectcategory=group)(name=$distro))"
$distro = $find.findone()
$distro = [adsi]$distro.path
$distro.grouptype = 8
$distro.setinfo()
Write-Host "$distro Converted"}
}