$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"
$age = ((get-date).adddays(-30))
$date = $age.toshortdatestring()
$date = $date.split("/")
$date = $date[2] + $date[0] + $date[1]
$outfile = "$env:temp\winhck.txt"
ri $outfile
Add-Content "Name`tReboots`tErrors`tC:Freespace`tLastboot" -path $outfile
$error.clear()

$list = get-content C:\users\kdemers\desktop\serverlist.txt #$find.findall()

ForEach($itm in $list){
	$comp = $itm # [string]$itm.properties.name
	Write-Host $comp
	$startups = (gwmi win32_ntlogevent -computer $comp -filter "Logfile='System' and EventCode='6009'" | ?{$_.timewritten.substring(0,7) -ge $date}).count #(get-eventlog -computer $comp -logname System -after $age | ?{$_.eventid -eq "6009"}).count
	$errors = (get-eventlog -computer $comp -logname System -entrytype Error -after $age).count
	$drive = gwmi win32_logicaldisk -computer $comp  | Where {$_.deviceid -eq "c:"}
	$drive = ((($drive.freespace /1GB)/($drive.size /1GB)) * 100).tostring().substring(0,2).replace(".","")
	$lastboot = [system.management.managementdatetimeconverter]::ToDateTime((gwmi -computer $comp -class win32_operatingsystem).lastbootuptime)

	$output = $comp + "`t" + $startups + "`t" + $errors + "`t" + $drive + "`t" + $lastboot
	Write-Host $output
	Add-Content $output -path $outfile
}

$smtpserver = "smtprelay.yourdomain.com"
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = “scripted@yourdomain.com”
$msg.To.Add(”user@yourdomain.com”)
$msg.Subject = “Domain OS Health”
$msg.Body = "Attached"

$att = new-object Net.Mail.Attachment($outfile)
$msg.Attachments.Add($att)

$smtp.Send($msg)

$att.dispose()
$msg.dispose()