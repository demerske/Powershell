$find = new-object system.directoryservices.directorysearcher
#sroots is LDAP connection string array for all domains
$sroots = @()
ri "$env:temp\teams.txt"
$find.filter = "(&(objectcategory=user)(objectclass=user))"

ForEach($sroot in $sroots){
	$find.searchroot = $sroot
	$master = $find.findall()

	ForEach($user in $master){
		$team = [string]$user.properties.extensionattribute12
		Add-content $team -path "$env:temp\teams.txt"
	}
}

$teams = get-content "$env:temp\teams.txt"
$teams = $teams | Select -unique

$find.searchroot = $null
$root = [ADSI]"LDAP://OU=Your security Groups,DC=yourdomain,DC=com"

ForEach($team in $teams){
	If($team -ne ""){
		$find.filter = "(&(objectcategory=group)(name=$team))"
		$test = $find.findall()
		If($test.count -eq 0){
			$ngroup = $root.Create("group","CN=" + $team)
			$ngroup.put("samaccountname",$team)
			$ngroup.setinfo()
			Write-Host "$team`tCreated"
		}
	}
}

$find.searchroot = $null
$root = [ADSI]"LDAP://OU=your Distribution,OU=Groups,DC=yourdomain,DC=com"

ForEach($team in $teams){
	If($team -ne ""){
		If($team.contains("TM_")){
			$team = $team.replace("TM_","TMD_")
			$find.filter = "(&(objectcategory=group)(name=$team))"
			$test = $find.findall()
			If($test.count -eq 0){
				$ngroup = $root.Create("group","CN=" + $team)
				$ngroup.put("samaccountname",$team)
				$ngroup.setinfo()
				Write-Host "$team`tCreated"
			}
		}
	}
}