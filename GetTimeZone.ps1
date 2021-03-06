$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"

$list = $find.findall()

ForEach($itm in $list){
	$comp = [string]$itm.properties.name
	$ip = [System.Net.DNS]::GetHostAddresses("$system")
	$ip = $ip[0]
	$tz = (gwmi win32_timezone -computer $comp).caption
	$output = $comp + "`t" + $ip + "`t" + $tz
	#Write-Host $output
	Add-Content $output -path "$env:userprofile\desktop\tzreport.txt"
}