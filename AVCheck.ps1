$find = new-object system.directoryservices.directorysearcher
$find.searchroot = $null
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"
$dom = $env:userdnsdomain
$outfile = "$env:userprofile\desktop\AVTest(" + $dom + "Domain).txt"
ri $outfile
$header = "System`tBusiness Owner`tTechnical Owner`tIP`tWMI`tSophos`tNorton`tDomain"
Add-Content $header -path $outfile

$list = $find.findall()

ForEach($itm in $list){
	$comp = [string]$itm.properties.name
	$bo = $itm.properties.givenname
	$to = $itm.properties.middlename
	$os = [string]$itm.properties.operatingsystem
	$ping = test-connection $comp -count 2 -quiet
	If($ping -eq $false){$output = $comp + "`t" + $bo + "`t" + $to + "`tOffline`t`t`t`t" + $dom}
	Else{
		$ip = [System.Net.DNS]::GetHostAddresses("$comp")
		$error.clear()
		If($os -eq "Windows 2000 Server"){$output = $comp + "`t" + $bo + "`t" + $to + "`t" + $ip + "`tWin2k`t`t`t" + $dom}
		Else{
			$wmi = gwmi win32_bios -computer $comp
			If($error[0] -ne $null){
				$err = $error[0].exception.message.tostring()
				$err = $err.substring(0,$err.indexof(".") + 1)
				$output = $comp + "`t" + $bo + "`t" + $to + "`t" + $ip + "`t" + $err + "`t`t`t" + $dom
				$error.clear()
			}
			Else{
				$svcs = gwmi win32_service -computer $comp
				$soph = "Not Installed"
				$nort = "Not Installed"
				foreach($svc in $svcs){
					If($svc.name -eq "SAVService"){$soph = $svc.state}
					If($svc.name -eq "Symantec AntiVirus"){$nort = $svc.state}
					$output = $comp + "`t" + $bo + "`t" + $to + "`t" + $ip + "`tPassed`t" + $soph + "`t" + $nort + "`t" + $dom
				}
			}
		}
	}
	Write-Host $output
	Add-Content $output -path $outfile
}

$smtpserver = #SMTP Relay Server
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = "auto.audit@yourdomain.com"
$msg.To.Add("user@yourdomain.com")
$msg.Subject = "Up/down AV and WMI Check for $dom"
$msg.body = "Here is the report"
$att = new-object Net.Mail.Attachment($outfile)
$msg.Attachments.Add($att)

$smtp.Send($msg)

$att.dispose()
$msg.dispose()