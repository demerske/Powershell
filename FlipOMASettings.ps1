#========================================================================
# Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.0.2
# Created on:   05/10/2012 10:14 AM
# Created by:   Kevin DeMers
# Organization: Nelnet, Inc.
# Filename:    	FlipOMASettings.ps1
#========================================================================
$error.clear()


$find = New-Object System.DirectoryServices.DirectorySearcher
$find.SearchRoot = "LDAP://yourdomain.com"
$find.Filter = "(&(objectcategory=group)(name=ActiveSyncUsers))"
$alist = $find.FindOne()
$alistdn = [string]$alist.properties.distinguishedname
$alist = [adsi]"LDAP://yourdomain.com/$alistdn"
$alist = $alist.member

$find.Filter = "(objectcategory=user)"
$find.searchroot = "LDAP://yourdomain.com/OU=User Accounts,DC=us,DC=nelnet,DC=biz"
$find.PageSize = 1000000

$dlist = $find.FindAll()

ForEach($usr in $dlist){$usrdn = [string]$usr.properties.distinguishedname
	$usr = [adsi]"LDAP://yourdomain.com/$usrdn"
	if($alist -contains $usrdn){
		$oma = 0
	}
	Else{
		$oma = 7
	}
	$usr.msexchomaadminwirelessenable = $oma
	$usr.setinfo()
	Write-Host $usr.Name, $oma
	If($error[0].exception -ne $null){
		Write-Host $usr.Name, "Failed"
		$error.clear()
	}
}