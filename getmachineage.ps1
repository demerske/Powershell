$outpath = Read-Host "Enter Output filepath"
$search = new-object System.directoryservices.directorysearcher
$search.filter = "(objectcategory=computer)" 
$search.SearchScope = "Subtree"
$search.PageSize = 10000
$systems = $search.findall()

ForEach($system in $systems){
	$logon = [datetime]::fromfiletime($system.properties.lastlogontimestamp[0])
	$name = $system.properties.name
	$dn = $system.properties.distinguishedname
	$output = $name + "`t" + $dn + "`t" + $logon
	Write-Host $output
	Add-Content $output -path $outpath
}