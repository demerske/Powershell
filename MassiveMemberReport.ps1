$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000
$master = get-content "$env:userprofile\desktop\list.txt"

ForEach($a in $master){
	$find.filter = "(&(objectcategory=group)(name=$a))"
	$group = $find.findone()
	$groupname = $group.properties.name
	$prefix = "$env:userprofile\desktop\RemainingGroups"
	$outfile = "$prefix\wipegroups.txt"
	ri $outfile
	
	$output = "Groupname`tName`tLogon`tDescription`tAccountExpire`tPasswordExpire`tLastLogon`tLastPWChange`tManager"
	add-content $output -path $outfile
	$members = $group.properties.member
	
	ForEach($member in $members){
		$find.filter = "(distinguishedname=$member)"
		$member = $find.findone()
		
		If($member.properties.objectcategory -match "CN=Person*"){
			$type = "user"
			$disabled = ([adsi] $member.path).psbase.invokeget("AccountDisabled")
			$manager = $member.properties.manager
			$desc = $member.properties.description
			$mname = $member.properties.name
			$sname = $member.properties.samaccountname
			$dn = [string]$member.properties.distinguishedname
			$expire = $member.properties.accountexpires[0]
			$pwexpire = $member.properties.useraccountcontrol
			If($manager -eq $null){$manager = "blank"}
			Else{
				$b = [string] $manager
				$manager = ([adsi] "LDAP://$b").name
			}
			If($pwexpire -eq "66048"){$pwexpire = "False"}
			Else{$pwexpire = "True"}
			If(($expire -eq "0") -or ($expire -eq "9223372036854775807")){$expire = "False"}
			Else{$expire = [datetime]::fromfiletime($member.properties.accountexpires[0])}
			If($member.properties.lastlogontimestamp -eq $null){$lastlog = "Never"}
			Else{$lastlog = [datetime]::fromfiletime([string]$member.properties.lastlogontimestamp)}
			If([string]$member.properties.pwdlastset -eq 0){$lastpass = "Never"}
			Else{$lastpass = [datetime]::fromfiletime([string]$member.properties.pwdlastset)}

			$output = [string] $a + "`t" + $mname + "`t" + $sname + "`t" + $desc + "`t" + $expire + "`t" + $pwexpire + "`t" + $lastlog + "`t" + $lastpass + "`t" + $manager

			Write-Host $output
			Add-Content $output -path $outfile
		}
		ElseIf($member.properties.objectcategory -match "CN=Group"){
		}
	}
}
		
$file = $outfile
			
$excelApp = New-Object -ComObject Excel.Application
$objWorkbook = $excelApp.Workbooks.Open($file)
$excelapp.worksheets.item(1).usedrange.entirecolumn.autofilter()
$excelapp.worksheets.item(1).usedrange.entirecolumn.autofit()
$file = $file.Substring(0, $file.Length - 3) + "xls"
Remove-Item $file
$error.clear()
$objWorkbook.SaveAs($file, 1)
$objWorkbook.Close()
$excelapp.quit()
Remove-Variable excelapp
[gc]::collect()
#ri "$prefix\*.txt"