#$erroractionpreference = "SilentlyContinue"
$find = new-object system.directoryservices.directorysearcher

$list = get-content "$env:userprofile\desktop\list.txt"

ForEach($itm in $list){
	$find.filter = "(&(objectcategory=group)(name=$itm))"
	$obj = $find.findone()
	$obj = [adsi]$obj.path
	$type = $obj.samaccounttype.tostring()
	If($type -eq "268435456"){$type = "Security"}
	If($type -eq "268435457"){$type = "Distribution"}
	$obj.extensionattribute10 = "Validated"
	#$obj.putex(1,"extensionattribute10",0)
	If($error[0].exception -ne $null){
		Write-Host "$itm $type"
		$error.clear()
	}
	Else{$obj.setinfo()}
}