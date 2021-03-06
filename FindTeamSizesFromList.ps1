$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 1000000

$list = get-content $env:userprofile\desktop\missing.txt

ForEach($itm in $list){
	$find.filter = "(&(objectcategory=user)(extensionattribute12=$itm))"
	$members = $find.findall()
	$count = $members.count
	$output = $itm + "`t" + $count
	Write-Host $output
	Add-Content $output -path "$env:userprofile\desktop\newtoadd.txt"
}