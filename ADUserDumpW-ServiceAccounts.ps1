$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=user)(objectclass=user))"
$find.pagesize = 100000
$file = "$env:userprofile\desktop\All Domain Users.txt"
ri $file

$list = $find.findall()

$output = "Display Name`tFirst Name`tLast Name`tDescription`tLocation`tCompany`tDepartment`tCost Center`tTitle`tEmployee Type`tClock`tManager`tOffice`tCell`tPager`tLast Logon`tPassword Changed"
Add-content $output -path $file

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
	$lastp = [datetime]::fromfiletime([string]$itm.properties.pwdlastset)
	$l = [string]$itm.properties.l
	$st = [string]$itm.properties.st
	$loc = $l + ", " + $st
	$mgr = [string] $itm.properties.manager
	If($mgr -ne ""){
		$mgr = [adsi] "LDAP://$mgr"
		$mgr = $mgr.name.tostring()
	}
	Else{$mgr = ""}
	$last = [datetime]::fromfiletime([string]$itm.properties.lastlogontimestamp)

	$output = [string] $name + "`t" + $fname + "`t" + $lname + "`t" + $desc + "`t" + $loc + "`t" + $comp + "`t" + $dept + "`t" + $deptn + "`t" + $title + "`t" + $emptyp + "`t" + $eid + "`t" + $mgr + "`t" + $ophone + "`t" + $mphone + "`t" + $pager + "`t" + $last + "`t" + $lastp
	Add-Content $output -path $file
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