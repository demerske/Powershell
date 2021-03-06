$find = new-object system.directoryservices.directorysearcher
$csv = "$env:userprofile\desktop\ecosystems.csv"
$list = import-csv $csv

ForEach($itm in $list){
	$name = $itm.servername
	$eco = $itm.ecosystem
	$sub = $itm.Environment
	$env = $itm.usestate
	$bown = $itm.businessowner
	$town = $itm.technicalowner

	If($bown -ne ""){
		$find.filter = "(name=$bown)"
		$bown = $find.findone()
		$bown = [string]$bown.properties.distinguishedname
	}

	If($town -ne ""){
		$find.filter = "(name=$town)"
		$town = $find.findone()
		$town = [string]$town.properties.distinguishedname
	}

	$find.filter = "(&(objectcategory=computer)(name=$name))"
	$comp = $find.findone()
	$comp = [string]$comp.path
	$comp = [adsi]$comp
	If($eco -ne ""){$comp.department = $eco}
	If($sub -ne ""){$comp.departmentnumber = $sub}
	If($env -ne ""){$comp.businesscategory = $env}
	If($bown -ne ""){$comp.managedby = $bown}
	IF($town -ne ""){$comp.manager = $town}
	$comp.setinfo()
}

If($error[0].exception -eq $null){ri $csv}