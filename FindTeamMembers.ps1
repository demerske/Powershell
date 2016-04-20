$find = new-object system.directoryservices.directorysearcher
$team = Read-Host "Team Name"
$find.filter = "(&(objectcategory=user)(extensionattribute12=$team))"

$list = $find.findall()

ForEach($itm in $list){
	$user = ([adsi]$itm.path).name
	Write-Host $user
}