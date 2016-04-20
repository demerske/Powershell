$find = new-object system.directoryservices.directorysearcher
$find.searchroot = $Null
$team = Read-Host "Enter Team"
$find.filter = "(&(objectcategory=user)(extensionattribute12=$team))"

$list = $find.findall()

ForEach($itm in $list){
	Write-Host $itm.properties.name
	Write-Host $itm.properties.manager
}