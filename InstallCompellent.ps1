$infile = Read-Host "Enter list filepath"
$list = get-content $infile
$sourcefile = "pathto\servicemanager.msi"

ForEach($itm in $list){copy $sourcefile "\\$itm\c$\"}

ForEach($itm in $list){schtasks /Create /S $itm /RU SYSTEM /SC ONCE /TN compellentservice /TR "c:\servicemanager.msi /q /norestart"}

ForEach($itm in $list){schtasks /run /tn "compellentservice"}