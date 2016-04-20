$sid = Read-Host "Enter Sid"

$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=user)(objectsid=$sid))"

$list = $find.findall()

ForEach($itm in $list){Write-Host $itm.properties.name}

