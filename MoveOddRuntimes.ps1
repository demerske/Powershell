Add-PSSnapin VMWare.VIMAutomation.Core

Connect-VIServer VSphereServer

$infile = Read-Host "Enter listpath"

$vmhosts = @(#array of vm hosts#)
$i = 0

$list = get-content $infile

ForEach($itm in $list){
    If($i -eq $vmhosts.count){$i = 0}
    $dest = $vmhosts[$i]
    Move-VM $itm -destination $dest -runasync -whatif
    $i++
}