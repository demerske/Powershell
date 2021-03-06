$domain = Read-Host "Enter domain:"

$header = "Group Name`tMemberName`tMembertype`tDescription`tSamAccountName`tAccountExpires`tLastLogon`tLastPasswordChange`tPasswordExpires`tLastModified`tManager`tAccountDisabled"

$find = new-object system.directoryservices.directorysearcher 
$admingrps = get-content "$env:userprofile\desktop\list.txt"


ForEach($grp in $admingrps){
	$find.filter = "(&(objectcategory=group)(name=$grp))"
	$grp = $find.findone()
	$grouproot = [string] $grp.properties.name

	$outfile = "$env:userprofile\desktop\memberships\" + $domain + "-" + $grouproot+ ".txt"
	Remove-Item $outfile
	$error.clear()

	#$grpcn = $grp.path
	#$grpcn = $grpcn.replace("LDAP://","")

	#$find.filter = "(memberof=$grpcn)"
	$members = $grp.properties.member #$find.findall()

	Add-Content $header -path $outfile
	
	ForEach($member in $members){
		$member = [adsi] "LDAP://$member"
		If($member.objectcategory -match "CN=Person*"){$type = "user"
			$disabled = $member.psbase.invokeget("AccountDisabled")
			$manager = $member.manager
			$desc = $member.description
			$mname = $member.name
			$sname = $member.samaccountname
			$dn = [string]$member.distinguishedname
			$pwexpire = $member.useraccountcontrol
			If($manager -eq $null){$manager = "blank"}
			Else{$a = [string] $manager
				$manager = ([adsi] "LDAP://$a").name
			}
			If($pwexpire -eq "66048"){$pwexpire = "False"}
			Else{$pwexpire = "True"}
			If($member.lastlogontimestamp -eq $null){$lastlog = "Never"}
			Else{$lastlog = [datetime]::fromfiletime([string]$member.lastlogontimestamp)}
			If([string]$member.properties.pwdlastset -eq 0){$lastpass = "Never"}
			Else{$lastpass = [datetime]::fromfiletime([string]$member.pwdlastset)}

			$output = [string] $grouproot + "`t" + $mname + "`t" + $type + "`t" + $desc + "`t" + $sname
			$output = [string] $output + "`t" + $lastlog + "`t" + $lastpass + "`t" + $pwexpire + "`t`t" + $manager + "`t" + $disabled
		}
		ElseIf($member.objectcategory -match "CN=Group*"){$type = "group"
			$modified = [string]$member.whenchanged
			$managedby = $member.managedby
			$mname = $member.name
			$desc = $member.description
			If($managedby -eq $null){$managedby = "Blank"}
			Else{$a = [string] $managedby
				$managedby = ([adsi] "LDAP://$a").name
			}
			$output = [string] $grouproot + "`t" + $mname + "`t" + $type + "`t" + $desc + "`t`t`t`t`t`t" + $modified + "`t" + $managedby
		}
		#Write-Host $output
		Add-Content $output -path $outfile
	}

	ForEach($member in $members){
		$member = [adsi] "LDAP://$member"

		If($member.objectcategory -match "CN=Group*"){

			Add-Content "" -path $outfile

			$sdn = $member.distinguishedname
			$groupname = $member.name
			$submembers = $member.member

			ForEach($sub in $submembers){
				$sub = [adsi] "LDAP://$sub"
				If($sub.objectcategory -match "CN=Person*"){$type = "user"
					$disabled = $sub.psbase.invokeget("AccountDisabled")
					$manager = $sub.manager
					$desc = $sub.description
					$mname = $sub.name
					$sname = $sub.samaccountname
					$dn = [string]$sub.distinguishedname
					$pwexpire = $sub.useraccountcontrol
					If($manager -eq $null){$manager = "blank"}
					Else{$a = [string] $manager
						$manager = ([adsi] "LDAP://$a").name
					}
					If($pwexpire -eq "66048"){$pwexpire = "False"}
					Else{$pwexpire = "True"}
					If($sub.lastlogontimestamp -eq $null){$lastlog = "Never"}
					Else{$lastlog = [datetime]::fromfiletime([string]$sub.lastlogontimestamp)}
					If([string]$sub.pwdlastset -eq 0){$lastpass = "Never"}
					Else{$lastpass = [datetime]::fromfiletime([string]$sub.pwdlastset)}

					$output = [string] $member.name + "`t" + $mname + "`t" + $type + "`t" + $desc + "`t" + $sname
					$output = [string] $output + "`t" + $lastlog + "`t" + $lastpass + "`t" + $pwexpire + "`t`t" + $manager + "`t" + $disabled
				}
				ElseIf($sub.objectcategory -match "CN=Group*"){$type = "group"
					$modified = [string]$sub.whenchanged
					$managedby = $sub.managedby
					$desc = $sub.description
					If($managedby -eq $null){$managedby = "Blank"}
					Else{$a = [string] $managedby
						$managedby = ([adsi] "LDAP://$a").name
					}
					$output = [string] $member.name + "`t" + $sub.name + "`t" + $type + "`t" + $desc + "`t`t`t`t`t`t" + $modified + "`t" + $managedby
				}
				#Write-Host $output
				Add-Content $output -path $outfile
			}
		}
	}
	
	$file = $outfile
	$smtpServer = “smtprelay.yourdomain.com”

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



	$msg = new-object Net.Mail.MailMessage
	$att = new-object Net.Mail.Attachment($file)
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)
	
	$msg.From = “scripted@yourdomain.com”
	$msg.To.Add(”user@yourdomain.com”)
	$msg.Subject = “$domain $grouproot Members and submembers”
	$msg.Body = “This is a list of the direct and 1 sublevel indirect members of the $grouproot group in the $domain domain.”
	$msg.Attachments.Add($att)

	$smtp.Send($msg)
	
	$att.dispose()
	$msg.dispose()
	
}