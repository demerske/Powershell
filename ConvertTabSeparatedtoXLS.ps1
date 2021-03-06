$list = gci "$env:userprofile\desktop\dataimports\txt"

ForEach($itm in $list){

$file = "$env:userprofile\desktop\dataimports\txt\" + $itm

	$smtpServer = "smtprelay.yourdomain.com"

	$excelApp = New-Object -ComObject Excel.Application
	$objWorkbook = $excelApp.Workbooks.Open($file)
	$excelapp.worksheets.item(1).usedrange.entirecolumn.autofilter()
	$excelapp.worksheets.item(1).usedrange.entirecolumn.autofit()
	$file = $file.Substring(0, $file.Length - 3) + "xls"
	Remove-Item $file
	$error.clear()
	$objWorkbook.SaveAs($file, 1)
	$objWorkbook.Close
	$excelapp.quit()
	Remove-Variable excelapp
	[gc]::collect()



	$msg = new-object Net.Mail.MailMessage
	$att = new-object Net.Mail.Attachment($file)
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)

	$msg.From = "scripted@yourdomain.com"
	$msg.To.Add("user@yourdomain.com")
	$msg.Subject = "$domain $grouproot Members and submembers"
	$msg.Body = "This is a list of the direct and 1 sublevel indirect members of the $grouproot group in the $domain domain."
	$msg.Attachments.Add($att)
	
	$smtp.Send($msg)
	
	$att.dispose()
	$msg.dispose()
	
}