$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000
$find.filter = "(objectcategory=printqueue)"

$list = $find.findall()

ForEach($itm in $list){
	$server = [string]$itm.properties.shortservername
	$printer = [string]$itm.properties.printername
	$output = $server + "`t" + $printer
	Write-Host $output
	Add-Content $output -path "$env:userprofile\desktop\domainprinters.txt"
}