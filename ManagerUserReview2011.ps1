$erroractionpreference = "Continue"
$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000
$mfind = new-object system.directoryservices.directorysearcher
$mfind.pagesize = 10000

$sroots = @(#array of LDAP connections e.g. "LDAP://DC=yourdomain,DC=com")

$uheader = "Display Name`tFirst Name`tLast Name`tDescription`tLocation`tCompany`tDepartment`tCost Center`tTitle`tEmployee Type`tClock`tManager`tOffice`tCell`tPager`tLast Logon`tPassword Changed`tComments"

#$mfirst = Read-Host "Enter First Name"
#$mlast = Read-Host "Enter Last Name"

$managers = get-content "$env:userprofile\desktop\list.txt"

ForEach($manager in $managers){

	$mfind.filter = "(&(objectcategory=user)(name=$manager))"
	$mgr = $mfind.findone()
	$mfirst = [string]$mgr.properties.givenname
	$mlast = [string]$mgr.properties.sn
	$email = [string]$mgr.properties.mail
	$mgr = [string]$mgr.properties.distinguishedname
	$prefix = "\\uhq-data-01\UserAccessReview2011\$mfirst-$mlast"
	if((test-path $prefix) -eq $false){mkdir $prefix}

	$outfile = "$prefix\$mfirst-$mlast-DirectReports.txt"
	ri $outfile
	$error.clear()
	Add-Content $uheader -path $outfile

	ForEach($sroot in $sroots){
		$find.searchroot = $sroot
		$find.filter = "(&(objectcategory=user)(manager=$mgr))"
		$users = $find.findall()
		ForEach($user in $users){
			$name = $user.properties.name
			$sname = $user.properties.samaccountname
			$fname = $user.properties.givenname
			$lname = $user.properties.sn
			$desc = $user.properties.description
			$comp = $user.properties.company
			$dept = $user.properties.department
			$deptn = $user.properties.departmentnumber
			$emptyp = $user.properties.employeetype
			$eid = $user.properties.employeeid
			$title = $user.properties.title
			$ophone = $user.properties.telephonenumber
			$mphone = $user.properties.mobile
			$pager = $user.properties.pager
			$lastp = [datetime]::FromFileTime([string]$user.properties.pwdlastset)
			$city = [string]$user.properties.l
			$state = [string]$user.properties.st
			$loc = "$city, $state"
			$mngr = $mgr.properties.name
			$lastlog = [datetime]::FromFileTime([string]$user.properties.lastlogontimestamp)
			
			$output = [string]$name + "`t" + $fname + "`t" + $lname + "`t" + $desc + "`t" + $loc + "`t" + $comp + "`t" + $dept + "`t" + $deptn + "`t" + $title + "`t" + $emptyp + "`t" + $eid + "`t" + $mngr + "`t" + $ophone + "`t" + $mphone + "`t" + $pager + "`t" + $lastlog + "`t" + $lastp
			Add-Content $output -path $outfile
		}
	}

	$excelApp = New-Object -ComObject Excel.Application
	$objWorkbook = $excelApp.Workbooks.Open($outfile)
	$sheet = $excelapp.worksheets.item(1)
	$sheet.usedrange.entirecolumn.autofilter()
	$sheet.usedrange.entirecolumn.autofit()
	$sheet.usedrange.wraptext = $true
	$excelapp.activewindow.splitcolumn = 1
	$excelapp.activewindow.splitrow = 1
	$excelapp.activewindow.freezepanes = $true
	$xls = $outfile.Substring(0, $outfile.Length - 3) + "xls"
	ri $xls
	$error.clear()
	$objWorkbook.SaveAs($xls, 1)
	$objWorkbook.Close()
	$excelapp.quit()
	Remove-Variable excelapp
	[gc]::collect()
	ri $outfile
	
	$smtpserver = "smtprelay.yourdomain.com"
	$msg = new-object Net.Mail.MailMessage
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)
	
	$msg.From = “user@yourdomain.com”
	#$msg.To.Add(”$email”)
	$msg.Bcc.Add("user@yourdomain.com")
	$msg.Subject = “Direct Reports Access Review - $mlast, $mfirst”
	$body = get-content "$env:userprofile\desktop\aduseraccess.htm"
	$msg.IsBodyHtml = 1
	$msg.Body = $body
	
	$att = new-object Net.Mail.Attachment($xls)
	$msg.Attachments.Add($att)
	
	$smtp.Send($msg)
	
	$att.dispose()
	$msg.dispose()
}