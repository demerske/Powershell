$list = get-content "Path to list file"
$tgt = Read-Host "Enter Target Email"
$subject = Read-Host "Enter Subject"
$body = Read-Host "Enter Body Text"

ForEach($itm in $list){

	$smtpserver = "smtprelay.yourdomain.com"
	$msg = new-object Net.Mail.MailMessage
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)

	$msg.From = $itm
	$msg.To.Add(”$tgt”)
	$msg.Subject = $subject
	$msg.Body = $body

	$smtp.Send($msg)

	$att.dispose()
	$msg.dispose()

}