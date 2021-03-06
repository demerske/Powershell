$file = "c:\scripting\output\Server Information Sheet.txt"
$fname = "Server Information Sheet.txt"

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
$fout = $fname.Substring(0, $fname.Length - 3) + "xls"
$fout = "\\server\sharename\$fout"
$web = $fname.substring(0, $fname.length - 3) + "htm"
$web = "\\server\sharename\$web"
Remove-Item $fout
Remove-Item $web
$error.clear()
$objWorkbook.SaveAs($fout, 1)
$objworkbook.SaveAs($web, 44)
$objWorkbook.Close()
$excelapp.quit()
Remove-Variable excelapp
[gc]::collect()

ri $file