$find = new-object system.directoryservices.directorysearcher
$file = "$env:userprofile\desktop\update.xls"

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
	$name = $itm.server
	$ip = $itm.ip

	$find.filter = "(&(objectcategory=computer)(name=$name))"
	$comp = $find.findone()
	$comp = [string]$comp.path
	$comp = [adsi]$comp
	if($ip -ne ""){$comp.iphostnumber = $ip}
	$comp.setinfo()
}

If($error[0].exception -eq $null){ri $csv}