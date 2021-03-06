$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000

$find.filter = "(&(objectcategory=group)(name=Maint_*))"
$list = $find.findall()

ForEach($itm in $list){
	$grp = [adsi]$itm.path
	$members = $grp.member
	ForEach($mem in $members){
		$grp.remove("LDAP://$mem")
	}
}

$find.filter = "(&(objectcategory=computer)(operatingsystem=*server*))"

$grpend = ",OU=Service,OU=Security,OU=Groups,DC=yourdomain,DC=com"
$pre = "CN=Maint_"

$master = $find.findall()

ForEach($obj in $master){
	$dn = [string]$obj.properties.distinguishedname
	$pday = [string]$obj.properties.extensionattribute1
	$ptm = [string]$obj.properties.extensionattribute2
	$rbt = [string]$obj.properties.extensionattribute3
	$exempt = [string]$obj.properties.extensionattribute4
	$pday = $pday.replace(" ","")

	If($exempt -ne ""){

		If($exempt -eq "Exempt"){
			$ptchgrp = $pre + "Exempt" + $grpend
		}
		ElseIf($rbt -eq "NoReboot"){
			$ptchgrp = $pre + $pday + $ptm + $rbt + $grpend
		}
		Else{
			$ptchgrp = $pre + $pday + $ptm + $grpend
		}
		Write-Host $ptchgrp

		$ptchgrp = [adsi] "LDAP://$ptchgrp"
		$members = $ptchgrp.member
		$ptchgrp.member = $members + $dn
		$ptchgrp.setinfo()
	}

	Else{
		$name = [string]$obj.properties.name
		Add-Content $name -path "$env:userprofile\desktop\nopatchinfo.txt"
	}
}
