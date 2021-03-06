$find = new-object system.directoryservices.directorysearcher
$find.searchroot = "LDAP://OU=Your Users,DC=yourdomain,DC=com"
$list = get-content "$env:userprofile\desktop\disableunused.txt"

ForEach($itm in $list){
	Write-Host $itm
	$Disabled = 0x0002
	$find.filter = "(name=$itm)"
	$acct = $find.findone()
	$user = [adsi] $acct.path
	$flags = [string] $user.useraccountcontrol
	$flip = $flags -band $a
	If($flip -eq 0){
		$flags = $flags -bxor $a
		$user.useraccountcontrol = $flags
		$user.setinfo()
	}
	$dn = [string] $acct.properties.distinguishedname
	move-adobject -identity $dn -targetpath "Distinguished name for disabled users container"
}