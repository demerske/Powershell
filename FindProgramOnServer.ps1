$outfile = "c:\scripting\txt\sqlservers.txt"
remove-item $outfile
$error.clear()
$search = new-object system.directoryservices.directorysearcher
$search.Filter = "(objectcategory=computer)"
$systems = $search.FindAll()
foreach($system in $systems){
	$system = [string]$system.Properties.name
	$serverkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$system)
	If($error[0].exception -ne $null){
		$output = $system + "`t" + $error[0].exception.message.tostring()
		Write-Host $output
		Add-Content $output -path $outfile
		$error.clear()
	}
	Else{
		$installs = @($serverkey.opensubkey("Software\Microsoft").getsubkeynames())
		ForEach($install in $installs){
			If($install.startswith("Microsoft SQL")){
				$output = $system + "`t" + $install
				Write-Host $output
				Add-Content $output -path $outfile
			}
		}
	}
}

$filename = $outfile
$smtpServer = “smtprelay.yourdomain.com”

$msg = new-object Net.Mail.MailMessage
$att = new-object Net.Mail.Attachment($filename)
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = “scripted@yourdomain.com”
$msg.To.Add(”user@yourdomain.com”)
$msg.Subject = “All SQL servers - Your Domain”
$msg.Body = “List of SQL servers in your domain”
$msg.Attachments.Add($att)

$smtp.Send($msg)