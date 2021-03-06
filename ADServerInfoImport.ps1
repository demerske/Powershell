$find = new-object system.directoryservices.directorysearcher
$file = Read-Host "Enter path of update Spreadsheet"

$excelApp = New-Object -ComObject Excel.Application
$excelapp.displayalerts=$false
$objWorkbook = $excelApp.Workbooks.Open($file)
$csv = $file.Substring(0, $file.Length - 3) + "csv"
Remove-Item $file
$error.clear()
$objWorkbook.SaveAs($csv, 6)
$objWorkbook.Close()
$excelapp.quit()
Remove-Variable excelapp
[gc]::collect()

$list = import-csv $csv

ForEach($itm in $list){
$name = $itm.servername
$desc = $itm.description
$plat = $itm.platform
$eco = $itm.ecosystem
$sub = $itm.subset
$env = $itm.environment
$pday = $itm.patchday
$ptm = $itm.patchtime
$rbt = $itm.reboot
$exempt = $itm.exemption
$rloc = $itm.racklocation
$bown = $itm.businessowner
$town = $itm.technicalowner

If($bown -ne ""){
$find.filter = "(name=$bown)"
$bown = $find.findone()
$bown = [string]$bown.properties.distinguishedname}

If($town -ne ""){
$find.filter = "(name=$town)"
$town = $find.findone()
$town = [string]$town.properties.distinguishedname}

$find.filter = "(&(objectcategory=computer)(name=$name))"
$comp = $find.findone()
$comp = [string]$comp.path
$comp = [adsi]$comp
If($desc -ne ""){$comp.description = $desc}
If($plat -ne ""){$comp.employeetype = $plat}
If($eco -ne ""){$comp.department = $eco}
If($sub -ne ""){$comp.departmentnumber = $sub}
If($env -ne ""){$comp.businesscategory = $env}
If($pday -ne ""){$comp.extensionattribute1 = $pday}
If($ptm -ne ""){$comp.extensionattribute2 = $ptm}
If($rbt -ne ""){$comp.extensionattribute3 = $rbt}
If($exempt -ne ""){$comp.extensionattribute4 = $exempt}
If($rloc -ne ""){$comp.physicaldeliveryofficename = $rloc}
If($bown -ne ""){$comp.managedby = $bown}
IF($town -ne ""){$comp.manager = $town}
$comp.setinfo()
}

If($error[0].exception -eq $null){ri $csv}