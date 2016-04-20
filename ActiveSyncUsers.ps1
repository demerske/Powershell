#========================================================================
# Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.0.2
# Created on:   05/10/2012 1:29 PM
# Created by:   kdemers
# Organization: 
# Filename:     
#========================================================================


$find = New-Object System.DirectoryServices.DirectorySearcher
$find.Filter = "(&(objectcategory=group)(name=ActiveSyncUsers))"
$grp = $find.FindOne()
$grp = [adsi]$grp.path
$grpmem = $grp.member

$list = Get-Content c:\scripting\txt\list.txt

ForEach($itm in $list){
	$find.Filter = "(&(objectcategory=user)(name=$itm))"
	$usr = $find.FindOne()
	If($usr -ne $null){
		$usrdn = [string]$usr.Properties.distinguishedname
		$usrp = $usr.Path
		$uname = [string]$usr.Properties.name
		$usr = [adsi]$usr.Path
		If($grpmem -notcontains $usrdn){
			$grp.add($usrp)
			$output = $uname + "`tAdded"
		}
		elseif($grpmem -contains $usrdn){
			$output = $uname + "`tAlready a Member"
		}
	}
	elseif($usr -eq $null){
		$output = $itm + "`tNot Found"
	}
	Write-Host $output
	Add-Content $output -Path "$env:userprofile\desktop\ActiveSyncUsersLog.txt"
}
	