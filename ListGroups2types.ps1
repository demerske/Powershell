$find = new-object system.directoryservices.directorysearcher
#$find.filter = "(&(objectcategory=group)(|(samaccounttype=536870912)(samaccounttype=268435456)))"#security
$find.filter = "(&(objectcategory=group)(|(samaccounttype=268435457)(samaccounttype=536870913)))"#distribution
$find.pagesize = 100000

$list = $find.findall()

ForEach($itm in $list){
	$name = [string]$itm.properties.name
	Write-Host $name
	Add-Content $name -path "$env:userprofile\desktop\distrogroups.txt"
}