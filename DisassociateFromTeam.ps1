$find = new-object system.directoryservices.directorysearcher
$fname = Read-Host "First Name"
$lname = Read-Host "Last Name"
$team = Read-Host "Team Name"

$find.filter = "(&((objectcategory=user)(sn=$lname)(givenname=$fname)))"

$list = $find.findall()

ForEach($itm in $list){
	$itm = [adsi]$itm.path
	Write-Host $itm.name
	#$itm.putex(1,"extensionattribute12",0)
	$itm.extensionattribute12 = [string]$team
	$itm.setinfo()
}