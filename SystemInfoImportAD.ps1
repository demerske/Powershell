$find = new-object system.directoryservices.directorysearcher "LDAP://yourdomain.com"
$list = import-csv "c:\scripting\output\ecosystems.csv"

ForEach($itm in $list){
	$name = $itm.name
	$eco = $itm.ecosystem
	$env = $itm.environment
	$bo = $itm.businessowner
	$to = $itm.technicalowner
	$use = $itm.usestate

	If($bo -ne ""){
		$find.filter = "(&(objectcategory=user)(name=$bo))"
		$bo = $find.findone()
		$bo = [string] $bo.properties.distinguishedname
	}

	If($to -ne ""){
		$find.filter = "(&(objectcategory=user)(name=$to))"
		$to = $find.findone()
		$to = [string] $to.properties.distinguishedname
	}

	$find.filter = "(&(objectcategory=computer)(name=$name))"
	$acct = $find.findone()
	If($acct -ne $null){
		$dn = [string] $acct.properties.distinguishedname
		$comp = [adsi] "LDAP://$dn"
		$comp.department = $eco
		If($env -ne ""){$comp.departmentnumber = $env}
		If($bo -ne ""){$comp.managedby = $bo}
		If($to -ne ""){$comp.manager = $to}
		If($use -ne ""){$comp.businesscategory = $use}
		$comp.setinfo()
		$output = $name + "`t" + $eco + "`tSuccess"
	}
	Else{$output = $name + "`t" + $eco + "`tFailure"}
	Write-host $output
	Add-content $output -path "c:\scripting\output\importfailure.txt"
}