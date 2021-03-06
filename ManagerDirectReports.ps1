$erroractionpreference = "Continue"
$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000

$sroots = @(#Array of LDAP connections e.g. "LDAP://OU=users,DC=yourdomain,DC=com")

$uheader = "Display Name`tFirst Name`tLast Name`tDescription`tLocation`tCompany`tDepartment`tCost Center`tTitle`tEmployee Type`tClock`tManager`tOffice`tCell`tPager`tLast Logon`tPassword Changed`tComments"

$mfirst = Read-Host "Enter First Name"
$mlast = Read-Host "Enter Last Name"

$find.searchroot = $null
$find.filter = "(&(&(objectcategory=user)(givenname=$mfirst)(sn=$mlast)))"
$mgr = $find.findone()
$mngr = $mgr.properties.name
$mfirst = [string]$mgr.properties.givenname
$mlast = [string]$mgr.properties.sn
$email = [string]$mgr.properties.mail
$mgr = [string]$mgr.properties.distinguishedname
$prefix = "$env:temp"
$pathtest = Test-Path $prefix
If($pathtest -eq $false){mkdir $prefix}

$outfile = "$prefix\$mfirst-$mlast-DirectReports.txt"
ri $outfile
Add-Content $uheader -path $outfile

ForEach($sroot in $sroots){
	$find.searchroot = $sroot
	$find.filter = "(&(objectcategory=user)(manager=$mgr))"
	$users = $find.findall()
	ForEach($user in $users){$name = $user.properties.name
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
		$team = $user.properties.extensionattribute12
		$lastp = [datetime]::FromFileTime([string]$user.properties.pwdlastset)
		$city = [string]$user.properties.l
		$state = [string]$user.properties.st
		$loc = "$city, $state"
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

$smtpserver = "smtprelay.yourdomain.com"
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = “scripted@yourdomain.com”
$msg.To.Add(”user@yourdomain.com”)
$msg.Subject = “$mfirst $mlast User list”
$body = "report"

$att = new-object Net.Mail.Attachment($xls)
$msg.Attachments.Add($att)

$smtp.Send($msg)

$att.dispose()
$msg.dispose()

$check = get-content "$prefix\$mfirst-$mlast-Directreports.txt"
Write-Host $check

ri "$prefix\$mfirst-$mlast-Directreports.txt"