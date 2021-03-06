$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=user)(objectclass=user))"
$find.pagesize = 100000
#sroots should be array of all LDAP connections for domains you want to search in
$sroots = @()
$file = "$env:temp\All Domain Users (Excluding Service Accounts OU).txt"
ri $file

$output = "Display Name`tFirst Name`tLast Name`tDescription`tLocation`tCompany`tDepartment`tCost Center`tTitle`tEmployee Type`tClock`tManager`tOffice`tCell`tPager`tLast Logon`tPassword Changed`tTeam"
Add-content $output -path $file

ForEach($sroot in $sroots){
	$find.searchroot = $sroot
	$list = $find.findall()

	ForEach($itm in $list){
		$name = $itm.properties.name
		$fname = $itm.properties.givenname
		$lname = $itm.properties.sn
		$desc = $itm.properties.description
		$comp = $itm.properties.company
		$dept = $itm.properties.department
		$deptn = $itm.properties.departmentnumber
		$emptyp = $itm.properties.employeetype
		$eid = $itm.properties.employeeid
		$title = $itm.properties.title
		$ophone = $itm.properties.telephonenumber
		$mphone = $itm.properties.mobile
		$pager = $itm.properties.pager
		$team = $itm.properties.extensionattribute12
		$lastp = [datetime]::fromfiletime([string]$itm.properties.pwdlastset)
		$loc = [string]$itm.properties.physicaldeliveryofficename
		$mgr = [string] $itm.properties.manager
		If($mgr -ne ""){
			$mgr = [adsi] "LDAP://$mgr"
			$mgr = $mgr.name.tostring()
		}
		Else{$mgr = ""}
		$last = [datetime]::fromfiletime([string]$itm.properties.lastlogontimestamp)
		
		$output = [string] $name + "`t" + $fname + "`t" + $lname + "`t" + $desc + "`t" + $loc + "`t" + $comp + "`t" + $dept + "`t" + $deptn + "`t" + $title + "`t" + $emptyp + "`t" + $eid + "`t" + $mgr + "`t" + $ophone + "`t" + $mphone + "`t" + $pager + "`t" + $last + "`t" + $lastp + "`t" + $team
		Add-Content $output -path $file
	}
}

$excelApp = New-Object -ComObject Excel.Application
$objWorkbook = $excelApp.Workbooks.Open($file)
$excelapp.worksheets.item(1).usedrange.entirecolumn.autofilter()
$excelapp.worksheets.item(1).usedrange.entirecolumn.autofit()
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

$msg.From = “scripted@yourdomain.com”
$msg.To.Add(”person@yourdomain.com”)
$msg.Subject = “AD Userlist - no services accounts”
$msg.Body = "Here is the list"

$att = new-object Net.Mail.Attachment($xls)
$msg.Attachments.Add($att)

$smtp.Send($msg)

$att.dispose()
$msg.dispose()