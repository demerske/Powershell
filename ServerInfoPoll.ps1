$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000
$inlist = Read-Host "Enter filepath of list"
$fname = "ServerInfoReport.txt"
$file = "$env:userprofile\desktop\$fname"
ri $file

$output = "System`tIP`tDescription`tOS`tPlatform`tEcosystem`tSubset`tEnvironment`tLocation`tBusinessOwner`tTechnicalOwner`tPatchDay`tPatchTime`tReboot`tPatchExemption`tRackLocation`tCreated`tMakeModel`tSerialNumber`tAssetTag"
Add-content $output -path $file

$list = get-content $inlist

ForEach($itm in $list){
$find.filter = "(&(objectcategory=computer)(name=$itm))"
$itm = $find.findone()
$sys = [string]$itm.properties.name
$desc = [string]$itm.properties.description
$os = [string]$itm.properties.operatingsystem
$sp = [string]$itm.properties.operatingsystemservicepack
$plat = [string]$itm.properties.employeetype
$eco = [string]$itm.properties.department
$sub = [string]$itm.properties.departmentnumber
$env = [string]$itm.properties.businesscategory
$loc = [string]$itm.properties.location
$bown = [string]$itm.properties.managedby
$town = [string]$itm.properties.manager
$pday = [string]$itm.properties.extensionattribute1
$ptm = [string]$itm.properties.extensionattribute2
$rbt = [string]$itm.properties.extensionattribute3
$exempt = [string]$itm.properties.extensionattribute4
$rloc = [string]$itm.properties.physicaldeliveryofficename
$create = [string]$itm.properties.whencreated
$mm = [string]$itm.properties.type
$sn = [string]$itm.properties.serialnumber
$at = [string]$itm.properties.roomnumber
$ip = [string]$itm.properties.iphostnumber

$osf = $os + " " + $sp

$bown = [adsi] "LDAP://$bown"
$bown = $bown.name

$town = [adsi] "LDAP://$town"
$town = $town.name

$output = $sys + "`t" + $ip + "`t" + $desc + "`t" + $osf + "`t" + $plat + "`t" + $eco + "`t" + $sub + "`t" + $env + "`t" + $loc + "`t" + $bown + "`t" + $town + "`t" + $pday + "`t" + $ptm + "`t" + $rbt + "`t" + $exempt + "`t" + $rloc + "`t" + $create + "`t" + $mm + "`t" + $sn + "`t" + $at
#Write-Host $output
add-content $output -path $file
}

$end = $true
If($end -eq $true){
$excelApp = New-Object -ComObject Excel.Application
$objWorkbook = $excelApp.Workbooks.Open($file)
$range = $excelapp.worksheets.item(1).usedrange
$range.entirecolumn.autofilter()
$range.entirecolumn.autofit()
$range.borders.linestyle = 1
$range.borders.weight = 2
$range.verticalalignment = -4160
$excelapp.worksheets.item(1).Columns.item(3).ColumnWidth = 100
$range.wraptext = $true
$excelapp.activewindow.splitcolumn = 1
$excelapp.activewindow.splitrow = 1
$excelapp.activewindow.freezepanes = $true
$xls = $file.substring(0, $file.length - 3) + "xls"
ri $xls
$error.clear()
$objWorkbook.SaveAs($xls, 1)
$objWorkbook.Close()
$excelapp.quit()
Remove-Variable excelapp
[gc]::collect()

ri $file}