Add-PSSnapin VMWare.VIMAutomation.Core

connect-viserver vmware server

$list = Get-VM

ForEach($itm in $list){$name = [string]$itm.name
$hostn = [string]$itm.vmhost.name
$output = $name + "`t" + $hostn
Write-Host $output
Add-Content $output -path "c:\scripting\output\vminfo.txt"
}