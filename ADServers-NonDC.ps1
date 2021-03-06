$outfile = "$env:userprofile\desktop\output2.txt"
$search = new-object system.directoryservices.directorysearcher
$search.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"
$search.pagesize = 100000
$SystemDN = $search.findall()

foreach($system in $systems){
	$sname = [string]$system.properties.name
	Add-Content $sname -path $outfile
}

$filename = $outfile
$smtpServer = "smtpserver.yourdomain.com"

$msg = new-object Net.Mail.MailMessage
$att = new-object Net.Mail.Attachment($filename)
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = "scripted@yourdomain.com"
$msg.To.Add("user@yourdomain.com")
$msg.Subject = "All AD Systems - NonDC's"
$msg.Body = "List of AD Systems attached. Now with teh emails!"
$msg.Attachments.Add($att)

$smtp.Send($msg)