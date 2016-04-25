$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 100000
$find.filter = "(objectcategory=group)"

$list = $find.findall()

ForEach($itm in $list){
	$itm = [adsi]$itm.path
	if([string]$itm.member -eq ""){
		$itm.extensionattribute10 = "Empty"
	}
	if([string]$itm.memberof -eq ""){
		$itm.extensionattribute11 = "Empty"
	}
	$itm.setinfo()
	Write-Host $itm.name
}