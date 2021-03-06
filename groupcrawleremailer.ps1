$fname = Read-Host "Enter First Name"
$lname = Read-Host "Enter Last Name"
$mail = Read-Host "Enter your email address"

$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(givenname=$fname)(sn=$lname))"
#$find.filter = "(samaccountname=$logon)"

$list = $find.findall()

If($list -ne $null){
	ForEach($itm in $list){
		$logon = $itm.properties.samaccountname
		$outfile = "$env:temp\$fname-$lname-$logon.txt"
		Remove-Item "$env:temp\sub*.txt"
		remove-item $outfile
		$error.clear()

		$membership = $itm.properties.memberof

		ForEach($grp in $membership){
			$a = $grp.split(",")
			$grp = $a[0]
			$grp = $grp.replace("CN=","")
			$grps = $grps + $grp
			#Write-Host $grp
			Add-Content $grp -path $outfile
		}

		$list1 = Get-Content $outfile

		ForEach($itm1 in $list1){
			$find.filter = "(name=$itm1)"
			$itm1 = $find.findone()
			If($itm1 -ne $null){
				$name = [string] $itm1.properties.name
				$memberof = $itm1.properties.memberof
				#Write-Host $name
				#Add-Content "" -path $outfile
				Add-Content $name -path $outfile
				If($memberof -ne $null){
					ForEach($grp in $memberof){
						$a = $grp.split(",")
						$grp = $a[0]
						$grp = $grp.replace("CN=","")
						#Write-Host $grp
						Add-Content $grp -path $outfile
						Add-Content $grp -path "$env:temp\sub1.txt"
					}
				}
			}
		}
		$list1 = Get-Content "$env:temp\sub1.txt"

		ForEach($itm1 in $list1){
			$find.filter = "(name=$itm1)"
			$itm1 = $find.findone()
			If($itm1 -ne $null){
				$name = [string] $itm1.properties.name
				$memberof = $itm1.properties.memberof
				#Write-Host $name
				#Add-Content "" -path $outfile
				Add-Content $name -path $outfile
				If($memberof -ne $null){
					ForEach($grp in $memberof){
						$a = $grp.split(",")
						$grp = $a[0]
						$grp = $grp.replace("CN=","")
						#Write-Host $grp
						Add-Content $grp -path $outfile
						Add-Content $grp -path "$env:temp\sub2.txt"
					}
				}
			}
		}

		$list1 = Get-Content "$env:temp\sub2.txt"

		ForEach($itm1 in $list1){
			$find.filter = "(name=$itm1)"
			$itm1 = $find.findone()
			If($itm1 -ne $null){
				$name = [string] $itm1.properties.name
				$memberof = $itm1.properties.memberof
				#Write-Host $name
				#Add-Content "" -path $outfile
				Add-Content $name -path $outfile
				If($memberof -ne $null){
					ForEach($grp in $memberof){
						$a = $grp.split(",")
						$grp = $a[0]
						$grp = $grp.replace("CN=","")
						#Write-Host $grp
						Add-Content $grp -path $outfile
						Add-Content $grp -path "$env:temp\sub3.txt"
					}
				}
			}
		}

		$list1 = Get-Content "$env:temp\sub3.txt"

		ForEach($itm1 in $list1){
			$find.filter = "(name=$itm1)"
			$itm1 = $find.findone()
			If($itm1 -ne $null){
				$name = [string] $itm1.properties.name
				$memberof = $itm1.properties.memberof
				#Write-Host $name
				#Add-Content "" -path $outfile
				Add-Content $name -path $outfile
				If($memberof -ne $null){
					ForEach($grp in $memberof){
						$a = $grp.split(",")
						$grp = $a[0]
						$grp = $grp.replace("CN=","")
						#Write-Host $grp
						Add-Content $grp -path $outfile
						Add-Content $grp -path "$env:temp\sub4.txt"
					}
				}
			}
		}

		$list1 = Get-Content "$env:temp\sub4.txt"

		ForEach($itm1 in $list1){
			$find.filter = "(name=$itm1)"
			$itm1 = $find.findone()
			If($itm1 -ne $null){
				$name = [string] $itm1.properties.name
				$memberof = $itm1.properties.memberof
				#Write-Host $name
				#Add-Content "" -path $outfile
				Add-Content $name -path $outfile
				If($memberof -ne $null){
					ForEach($grp in $memberof){
						$a = $grp.split(",")
						$grp = $a[0]
						$grp = $grp.replace("CN=","")
						#Write-Host $grp
						Add-Content $grp -path $outfile
						Add-Content $grp -path "$env:temp\sub5.txt"
					}
				}
			}
		}

		$list1 = Get-Content "$env:temp\sub5.txt"

		ForEach($itm1 in $list1){
			$find.filter = "(name=$itm1)"
			$itm1 = $find.findone()
			If($itm1 -ne $null){
				$name = [string] $itm1.properties.name
				$memberof = $itm1.properties.memberof
				#Write-Host $name
				#Add-Content "" -path $outfile
				Add-Content $name -path $outfile
				If($memberof -ne $null){
					ForEach($grp in $memberof){
						$a = $grp.split(",")
						$grp = $a[0]
						$grp = $grp.replace("CN=","")
						#Write-Host $grp
						Add-Content $grp -path $outfile
						Add-Content $grp -path "$env:temp\sub6.txt"
					}
				}
			}
		}

		$list1 = Get-Content "$env:temp\sub6.txt"

		ForEach($itm1 in $list1){
			$find.filter = "(name=$itm1)"
			$itm1 = $find.findone()
			If($itm1 -ne $null){
				$name = [string] $itm1.properties.name
				$memberof = $itm1.properties.memberof
				#Write-Host $name
				#Add-Content "" -path $outfile
				Add-Content $name -path $outfile
				If($memberof -ne $null){
					ForEach($grp in $memberof){
						$a = $grp.split(",")
						$grp = $a[0]
						$grp = $grp.replace("CN=","")
						#Write-Host $grp
						Add-Content $grp -path $outfile
						Add-Content $grp -path "$env:temp\sub7.txt"
					}
				}
			}
		}

		$list1 = Get-Content "$env:temp\sub7.txt"

		ForEach($itm1 in $list1){
			$find.filter = "(name=$itm1)"
			$itm1 = $find.findone()
			If($itm1 -ne $null){
				$name = [string] $itm1.properties.name
				$memberof = $itm1.properties.memberof
				#Write-Host $name
				#Add-Content "" -path $outfile
				Add-Content $name -path $outfile
				If($memberof -ne $null){
					ForEach($grp in $memberof){
						$a = $grp.split(",")
						$grp = $a[0]
						$grp = $grp.replace("CN=","")
						#Write-Host $grp
						Add-Content $grp -path $outfile
						Add-Content $grp -path "$env:temp\sub8.txt"
					}
				}
			}
		}

		$list1 = Get-Content "$env:temp\sub8.txt"

		ForEach($itm1 in $list1){
			$find.filter = "(name=$itm1)"
			$itm1 = $find.findone()
			If($itm1 -ne $null){
				$name = [string] $itm1.properties.name
				$memberof = $itm1.properties.memberof
				#Write-Host $name
				#Add-Content "" -path $outfile
				Add-Content $name -path $outfile
				If($memberof -ne $null){
					ForEach($grp in $memberof){
						$a = $grp.split(",")
						$grp = $a[0]
						$grp = $grp.replace("CN=","")
						#Write-Host $grp
						Add-Content $grp -path $outfile
						Add-Content $grp -path "$env:temp\sub9.txt"
					}
				}
			}
		}

		$list1 = Get-Content "$env:temp\sub9.txt"

		ForEach($itm1 in $list1){
			$find.filter = "(name=$itm1)"
			$itm1 = $find.findone()
			If($itm1 -ne $null){
				$name = [string] $itm1.properties.name
				$memberof = $itm1.properties.memberof
				#Write-Host $name
				#Add-Content "" -path $outfile
				Add-Content $name -path $outfile
				If($memberof -ne $null){
					ForEach($grp in $memberof){
						$a = $grp.split(",")
						$grp = $a[0]
						$grp = $grp.replace("CN=","")
						#Write-Host $grp
						Add-Content $grp -path $outfile
						Add-Content $grp -path "$env:temp\sub10.txt"
					}
				}
			}
		}

		$unique = Get-Content $outfile
		$unique = $unique | Select -unique
		Remove-Item $outfile
		ForEach($line in $unique){
			Add-Content $line -path $outfile
		}

		$file = $outfile
		$smtpServer = “smtprelay.yourdomain.com”

		$msg = new-object Net.Mail.MailMessage
		$att = new-object Net.Mail.Attachment($file)
		$smtp = new-object Net.Mail.SmtpClient($smtpServer)
		
		$msg.From = “scripted@yourdomain.com”
		$msg.To.Add(”$mail”)
		$msg.Subject = “Group Membership list for $fname $lname - $logon”
		$msg.Body = “This is a list of direct and indirect group membership for $fname $lname on acccount $logon.”
		$msg.Attachments.Add($att)
		
		$smtp.Send($msg)

		$att.dispose()
		$msg.dispose()
	}
}