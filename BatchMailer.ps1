$find = new-object system.directoryservices.directorysearcher

$list = get-content "$env:userprofile\desktop\maillist.txt"

ForEach($itm in $list){
	$find.filter = "(name=$itm)"
	$obj = $find.findone()
	$email = $obj.properties.proxyaddresses[0]
	$email = $email.replace("smtp:","")

	Write-Host $email

	$smtpserver = "smtprelay.yourdomain.com"
	$msg = new-object Net.Mail.MailMessage
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)

	$msg.From = "user@yourdomain.com"
	$msg.To.Add("$email")
	$msg.Subject = "Info Request - $itm"
	$msg.Body = "message body here"

	$smtp.Send($msg)

	$att.dispose()
	$msg.dispose()

}