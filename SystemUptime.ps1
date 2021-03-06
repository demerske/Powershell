$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=computer)(operatingsystem=*server*))"
$find.pagesize = 1000000
$error.clear()

$list = $find.findall()

ForEach($itm in $list){
	$comp = [string]$itm.properties.name
	$lastboot = [system.management.managementdatetimeconverter]::ToDateTime((gwmi -computer $comp -class win32_operatingsystem).lastbootuptime)
	If($error[0] -ne $null){
		$output = $comp + "`t" + $error[0].exception.message.tostring()
		$error.clear()
	}
	Else{$output = $comp + "`t" + $lastboot}
	Write-Host $output
	Add-Content $output -path "$env:userprofile\desktop\domainuptime.txt"
}