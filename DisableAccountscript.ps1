$outfile = "c:\temp\DisableSupportAccount.txt"
Remove-Item $outfile
$search = new-object system.directoryservices.directorysearcher
$search.filter = "(&(&(&(samAccountType=805306369)(!(primaryGroupId=516)))(objectCategory=computer)(operatingSystem=Windows Server*)))"
$systemDN = $search.findall()
ForEach($obj in $systemdn){$systems = $systems + $obj.properties.name}
ForEach($system in $systems){
	$users = ([adsi] "WinNT://$system").psbase.children | ?{$_.SchemaClassName -match "user"}
	If($error[0].exception -ne $null){
		$output = $system + "`t" + $error[0].exception.message.tostring()
		Add-Content $output -path $outfile
		$error.clear()
	}
	Else{
		ForEach($user in $users){
			if($user.Name -match "SUPPORT_388945a0"){$user.psbase.invokeset("AccountDisabled", "True") 
				$user.setinfo()
				$output = $system + "`t" + $user.Name
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
$msg.Subject = “Support_ accounts disabled - Your Domain”
$msg.Body = “Support accounts that have been disabled.”
$msg.Attachments.Add($att)

$smtp.Send($msg)