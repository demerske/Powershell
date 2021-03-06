$search = new-object system.directoryservices.directorysearcher
$search.filter = "(objectcategory=user)"
$search.pagesize = 10000
$col = $search.findall()

ForEach($itm in $col){
	If($itm.properties.samaccountname -ne $null){

		$user = [adsi]($itm.path)

		$groupID = $user.primaryGroupID

		$arrSID = $user.objectSid.Value

		$SID = New-Object System.Security.Principal.SecurityIdentifier ($arrSID,0)

		$groupSID = $SID.AccountDomainSid.Value + "-" + $user.primaryGroupID.ToString()

		$group = [adsi]("LDAP://<SID=$groupSID>")

		$output = $itm.properties.name + "`t" + $group.name

		Write-Host $output
	}
}