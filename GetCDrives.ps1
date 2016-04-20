#========================================================================
# Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.0.2
# Created on:   6/1/2012 10:36 AM
# Created by:   kdemers
# Organization: Nelnet, Inc
# Filename:     GetCDrive.ps1
#========================================================================

$erroractionpreference = "SilentlyContinue"

$domains = @(#array of domain names e.g. yourdomain.com#)

$file = "c:\scripting\output\cDrives.txt"
ri $file

$output = 
Add-content $output -path $file

ForEach($domain in $domains){
	$dom = "LDAP://$domain"

	$find = new-object system.directoryservices.directorysearcher
    $find.searchroot = $dom
	$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"
	$find.pagesize = 100000
	
	$list = $find.findall()
	
	ForEach($itm in $list){
		$comp = [string]$itm.properties.name
		$test = gwmi win32_bios -computername $comp
		If($error[0].exception -ne $null){
			$output = $comp + "`t" + $error[0].exception.message.tostring() + "`t`t" + $domain
			$error.clear()
		}
		Else{
			$os = (gwmi win32_operatingsystem -computername $comp).caption
			$disk = (gwmi win32_logicaldisk -computername $comp -filter "DeviceID='C:'").size / 1GB
			$disk = $disk.tostring().substring(0,$disk.tostring().indexof("."))
			$output = $comp + "`t" + $os + "`t" + $disk + "`t" + $domain
		}
		Write-Host $output
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