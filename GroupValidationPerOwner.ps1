$find = new-object system.directoryservices.directorysearcher
#$find.filter = "(objectcategory=group)" #"(&(objectcategory=group)(|(|(name=IND-*)(name=*BTS*)(name=JAX-*))))"
$find.pagesize = 10000
#$list = $find.findall()
$outpath = "$env:userprofile\desktop\groupreports"

$owners = get-content "$env:userprofile\desktop\list.txt"

ForEach($owner in $owners){
	$own = $owner.replace(",","").replace(" ","")
	$outfile = "$outpath\$own.txt"
	$find.filter = "(&(objectcategory=user)(name=$owner))"
	$owner = $find.findone()
	$email = $owner.properties.proxyaddresses[0].replace("smtp:","")
	$owner = $owner.properties.distinguishedname
	$find.filter = "(&(objectcategory=group)(managedby=$owner))"
	$list = $find.findall()
	ri $outfile

	$output = "Name`tDescription`tManager`tCreated`tModified`tType`tValidated`tComments"
	Add-content $output -path $outfile
	
	ForEach($itm in $list){
		If([string]$itm.properties.extensionattribute10 -eq ""){
			$name = [string]$itm.properties.name
			$mgr = [string]$itm.properties.managedby
			If($mgr -ne ""){
				$mgr = [adsi] "LDAP://$mgr"
				$mgr = $mgr.properties.name
			}
			$desc = [string]$itm.properties.description
			$desc = $desc.replace("`n"," ")
			$created = $itm.properties.whencreated
			$modified = $itm.properties.whenchanged
			$valid = $itm.properties.extensionattribute10
			If($itm.properties.samaccounttype -eq "268435456"){$type = "Security"}
			If($itm.properties.samaccounttype -eq "268435457"){$type = "Distribution"}
			
			$output = [string]$name + "`t" + $desc + "`t" + $mgr + "`t" + $created + "`t" +  $modified + "`t" + $type + "`t" + $valid
			
			#Write-Host $output
			Add-Content $output -path $outfile
		}
	}

	$file = $outfile
	$excelApp = New-Object -ComObject Excel.Application
	$objWorkbook = $excelApp.Workbooks.Open($file)
	$range = $excelapp.worksheets.item(1).usedrange
	$range.entirecolumn.autofilter()
	$range.entirecolumn.autofit()
	$range.borders.linestyle = 1
	$range.borders.weight = 2
	$range.verticalalignment = -4160
	$excelapp.worksheets.item(1).Columns.item(2).ColumnWidth = 100
	$range.wraptext = $true
	$excelapp.activewindow.splitcolumn = 1
	$excelapp.activewindow.splitrow = 1
	$excelapp.activewindow.freezepanes = $true
	$xls = $file.Substring(0, $file.Length - 3) + "xls"
	Remove-Item $xls
	$error.clear()
	$objWorkbook.SaveAs($xls, 1)
	$objWorkbook.Close()
	$excelapp.quit()
	Remove-Variable excelapp
	[gc]::collect()


	$smtpserver = "smtprelay.yourdomain.com"
	$msg = new-object Net.Mail.MailMessage
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)
	
	$msg.From = "user@yourdomain.com"
	$msg.To.Add("$email")
	$msg.Subject = "URGENT - Active Directory Group Validation"
	$msg.Body = "You have been identified as the owner of several Active Directory Groups. 
	Please review the attached list of groups and let me know if they are still valid and in use or not. 
	This is part of a cleanup effort to better organize and document our Active Directory environment as part 
	of an ongoing project to clean up and streamline our Infrastructure to better support the business needs 
	of the company. Feel free to contact me with any questions."
	
	$att = new-object Net.Mail.Attachment($xls)
	$msg.Attachments.Add($att)
	
	$smtp.Send($msg)
	
	$att.dispose()
	$msg.dispose()
	
}

ri "$outpath\*.txt"