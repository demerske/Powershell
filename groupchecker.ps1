$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000
$find.filter = "(objectcategory=group)"
$find.searchroot = $null

$list = $find.findall()
$i = 0
ForEach($itm in $list){
	$mems = $itm.properties.member
	$path = $itm.path.tostring().contains("OU=Managed Objects,")
	If(($path -eq $true) -and ($mems -eq $null)){$i = $i + 1
		Write-Host $itm.properties.name
	}
}
