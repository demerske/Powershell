$outfile = "$env:userprofile\desktop\javascrapeout.txt"
#remove-item $outfile
$error.clear()
#$search = new-object system.directoryservices.directorysearcher
#$search.Filter = "(objectcategory=computer)"
#$systemdn = $search.FindAll()
#foreach($obj in $systemdn){$systems = $systems + $obj.properties.name}
$systems = get-content "c:\users\kdemers\desktop\javascrape.txt"
foreach($system in $systems){
	$serverkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$system)
	If($error[0].exception -ne $null){
		$output = $system + "`t" + $error[0].exception.message.tostring()
		Write-Host $output
		Add-Content $output -path $outfile
		$error.clear()
	}
	Else{
		$installs = @($serverkey.opensubkey("Software\Microsoft\windows\currentversion\uninstall").getsubkeynames())
		ForEach($install in $installs){
			If($install.startswith("{3248F0A8-6813-11D6-A77B-00B0D01")){
				$output = $system + "`t" + $install
				Write-Host $output
				Add-Content $output -path $outfile
			}
		}
	}
}

$filename = $outfile
$smtpServer = "smtprelay.yourdomain.com"

$msg = new-object Net.Mail.MailMessage
$att = new-object Net.Mail.Attachment($filename)
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = "scripted@nelnet.net"
$msg.To.Add("user@yourdomain.com")
$msg.Subject = "Java Version Info"
$msg.Body = "Java Version Info"
$msg.Attachments.Add($att)

$smtp.Send($msg)