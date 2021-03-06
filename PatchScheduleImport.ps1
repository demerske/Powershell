$find = new-object system.directoryservices.directorysearcher "LDAP://yourdomain.com"
$list = get-content "$env:userprofile\desktop\patchschedule.txt"

ForEach($itm in $list){
	#$attr1 = "4th cycle"
	#$attr2 = "4am"
	#$attr3 = "Normal"
	$attr4 = "Exempt"

	$find.filter = "(&(objectcategory=computer)(name=$itm))"
	$acct = $find.findone()
	If($acct -ne $null){
		$dn = [string] $acct.properties.distinguishedname
		$comp = [adsi] "LDAP://$dn"
		#$comp.extensionattribute1 = $attr1
		#$comp.extensionattribute2 = $attr2
		#$comp.extensionattribute3 = $attr3
		$comp.extensionattribute4 = $attr4
		$comp.setinfo()
		$output = $itm + "`tSuccess"
	}
	Else{
		$output = $itm + "`tFailure"
	}
	Write-host $output
	Add-content $output -path "$env:userprofile\desktop\patchimportlog.txt"
}