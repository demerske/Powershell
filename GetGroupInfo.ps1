$list = Get-Content "$env:userprofile\desktop\list.txt"
$find = new-object system.directoryservices.directorysearcher


ForEach($itm in $list){
	$find.filter = "(name=$itm)"
	$obj = $find.findone()
	If($obj -ne $null){
		$name = [string] $obj.properties.name
		$desc = [string] $obj.properties.description
		$created = [string] $obj.properties.whencreated
		If($obj.properties.samaccounttype -eq "268435456"){$type = "Security"}
		If($obj.properties.samaccounttype -eq "268435457"){$type = "Distribution"}
		$output = $name + "`t" + $desc + "`t" + $created + "`t" + $type
	}
	Else{
		$name = $itm
		$desc = "Builtin"
		$output = $name + "`t" + $desc
	}
	Write-Host $output
	Add-Content $output -path "$env:userprofile\desktop\remaininggroups.txt"
}