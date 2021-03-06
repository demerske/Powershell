$find = new-object system.directoryservices.directorysearcher
$find.searchroot = "LDAP://DC=yourdomain,DC=com"
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"

$list = $find.findall()

ForEach($itm in $list){
	$name = [string]$itm.properties.name
	$fname = $name + ".yourdomain.com"
	$up = Test-Connection $fname -count 2 -quiet
	If($up -ne $false){
		$ip = [System.Net.DNS]::GetHostAddresses("$fname")
		$output = $name + "`t" + $ip
	}
	Else{$output = $name + "`tOffline"}
	Write-Host $output
	#Add-Content $output -path "$env:userprofile\desktop\allsystems.txt"	
}