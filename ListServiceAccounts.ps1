$header = "Group Name`tMemberName`tMembertype`tDescription`tSamAccountName`tAccountExpires`tLastLogon`tLastPasswordChange`tPasswordExpires`tManager"
$outfile = "c:\windows\temp\ServiceAccounts.txt"
Remove-Item $outfile
$error.clear()

$find = new-object system.directoryservices.directorysearcher
$find.SearchRoot = "LDAP://OU=Service Accounts,DC=yourdomain,DC=com"
$members = $find.findall()
$grouproot = "Service Accounts"

Add-Content $header -path $outfile

ForEach($member in $members){

	If($member.properties.objectcategory -match "CN=Person*"){
		$type = "user"
		$manager = $member.properties.manager
		$desc = $member.properties.description
		$mname = $member.properties.name
		$sname = $member.properties.samaccountname
		$dn = [string]$member.properties.distinguishedname
		$expire = $member.properties.accountexpires[0]
		$pwexpire = $member.properties.useraccountcontrol
		If($manager -eq $null){$manager = "blank"}
		Else{$a = [string] $manager
			$manager = ([adsi] "LDAP://$a").name
		}
		If($pwexpire -eq "66048"){$pwexpire = "False"}
		Else{$pwexpire = "True"}
		If(($expire -eq "0") -or ($expire -eq "9223372036854775807")){$expire = "False"}
		Else{$expire = [datetime]::fromfiletime($member.properties.accountexpires[0])}
		If([string]$member.properties.lastlogontimestamp -eq 0){$lastlog = "Never"}
		Else{$lastlog = [datetime]::fromfiletime([string]$member.properties.lastlogontimestamp)}
		If([string]$member.properties.pwdlastset -eq "0"){$lastpass = "Never"}
		Else{$lastpass = [datetime]::fromfiletime([string]$member.properties.pwdlastset)}

		$output = [string] $grouproot + "`t" + $mname + "`t" + $type + "`t" + $desc + "`t" + $sname + "`t" + $expire
		$output = [string] $output + "`t" + $lastlog + "`t" + $lastpass + "`t" + $pwexpire + "`t" + $manager
	}
	ElseIf($member.properties.objectcategory -match "CN=Group*"){
		$type = "group"
		$managedby = $member.properties.managedby
		$mname = $member.properties.name
		$desc = $member.properties.description
		If($managedby -eq $null){$managedby = "Blank"}
		Else{
			$a = [string] $managedby
			$managedby = ([adsi] "LDAP://$a").name
		}
		$output = [string] $grouproot + "`t" + $mname + "`t" + $type + "`t" + $desc + "`t`t`t`t`t" + $managedby
	}	
	Write-Host $output
	Add-Content $output -path $outfile
}

ForEach($member in $members){

	If($member.properties.objectcategory -match "CN=Group*"){

		Add-Content "" -path $outfile

		$find2 = New-Object system.directoryservices.directorysearcher
		$sdn = $member.properties.distinguishedname
		$groupname = $member.properties.name
		$find2.Filter = "(memberof=$sdn)"
		$submembers = $find2.findall()

		ForEach($sub in $submembers){

			If($sub.properties.objectcategory -match "CN=Person*"){
				$type = "user"
				$manager = $sub.properties.manager
				$desc = $sub.properties.description
				$mname = $sub.properties.name
				$sname = $sub.properties.samaccountname
				$dn = [string]$sub.properties.distinguishedname
				$expire = $sub.properties.accountexpires[0]
				$pwexpire = $sub.properties.useraccountcontrol
				If($manager -eq $null){$manager = "blank"}
				Else{
					$a = [string] $manager
					$manager = ([adsi] "LDAP://$a").name
				}
				If($pwexpire -eq "66048"){$pwexpire = "False"}
				Else{$pwexpire = "True"}
				If(($expire -eq "0") -or ($expire -eq "9223372036854775807")){$expire = "False"}
				Else{$expire = [datetime]::fromfiletime($sub.properties.accountexpires[0])}
				If([string]$sub.properties.lastlogontimestamp -eq 0){$lastlog = "Never"}
				Else{$lastlog = [datetime]::fromfiletime([string]$sub.properties.lastlogontimestamp)}
				If($sub.properties.pwdlastset -eq $null){$lastpass = "Never"}
				Else{$lastpass = [datetime]::fromfiletime([string]$sub.properties.pwdlastset)}

				$output = [string] $member.properties.name + "`t" + $mname + "`t" + $type + "`t" + $desc + "`t" + $sname + "`t" + $expire
				$output = [string] $output + "`t" + $lastlog + "`t" + $lastpass + "`t" + $pwexpire + "`t" + $manager
			}
			ElseIf($sub.properties.objectcategory -match "CN=Group*"){
				$type = "group"
				$managedby = $sub.properties.managedby
				$desc = $sub.properties.description
				If($managedby -eq $null){$managedby = "Blank"}
				Else{$a = [string] $managedby
					$managedby = ([adsi] "LDAP://$a").name
				}
			$output = [string] $member.properties.name + "`t" + $sub.properties.name + "`t" + $type + "`t" + $desc + "`t`t`t`t`t" + $managedby
			}
			Write-Host $output
			Add-Content $output -path $outfile
		}
	}
}

$file = $outfile
$smtpServer = "smtprelay.yourdomain.com"

$excelApp = New-Object -ComObject Excel.Application
$objWorkbook = $excelApp.Workbooks.Open($file)
$excelapp.worksheets.item(1).usedrange.entirecolumn.autofit()
$file = $file.Substring(0, $file.Length - 3) + "xls"
Remove-Item $file
$error.clear()
$objWorkbook.SaveAs($file, 1)
$objWorkbook.Close
$excelapp.quit()
Remove-Variable excelapp
[gc]::collect()



$msg = new-object Net.Mail.MailMessage
$att = new-object Net.Mail.Attachment($file)
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = "scripted@yourdomain.com"
$msg.To.Add("user@yourdomain.com")
$msg.Subject = "Domain Service Accounts"
$msg.Body = "This is a list of Service Accounts in the Domain"
$msg.Attachments.Add($att)

$smtp.Send($msg)

$att.dispose()
$msg.dispose()