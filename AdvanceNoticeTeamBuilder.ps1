$find = new-object system.directoryservices.directorysearcher
$team = Read-Host "Team Name"
$find.filter = "(&(objectcategory=user)(extensionattribute12=$team))"
$outfol = #path to output folder
$outpath = "$outfol\$team.txt"
ri $outpath
$list = $find.findall()

ForEach($itm in $list){
	$user = ([adsi]$itm.path).name
	Write-Host $user
	Add-Content $user -path $outpath
}