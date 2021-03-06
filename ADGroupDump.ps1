$outfile = "$env:userprofile\desktop\All Groups.txt" #Read-Host "Enter outfile"
Remove-Item $outfile
$find = new-object system.directoryservices.directorysearcher
$find.filter = "(objectcategory=group)"
$find.pagesize = 10000
$list = $find.findall()

$output = "Name`tDescription`tManager`tCreated`tModified`tType`tMembers`tMemberOf`tComments"
Add-content $output -path $outfile

ForEach($itm in $list){

	$name = [string]$itm.properties.name
	$mgr = [string]$itm.properties.managedby
    $mof = [string]$itm.properties.memberof
    $mems = [string]$itm.properties.member
	If($mgr -ne ""){
		$mgr = [adsi] "LDAP://$mgr"
		$mgr = $mgr.properties.name
	}
	$desc = [string]$itm.properties.description
	$desc = $desc.replace("`n"," ")
	$created = $itm.properties.whencreated
	$modified = $itm.properties.whenchanged
	If($mof -eq ""){$memofvalid = "Empty"}
    Else{$memofvalid = "True"}
    If($mems -eq ""){$memvalid = "Empty"}
    Else{$memvalid = "True"}
	If($itm.properties.samaccounttype -eq "268435456"){$type = "Security"}
	If($itm.properties.samaccounttype -eq "268435457"){$type = "Distribution"}
	
	$output = [string]$name + "`t" + $desc + "`t" + $mgr + "`t" + $created + "`t" +  $modified + "`t" + $type + "`t" + $memvalid + "`t" + $memofvalid

	Write-Host $output
	Add-Content $output -path $outfile
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

ri $file