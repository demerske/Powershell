Add-PSSnapin VMWare.VIMAutomation.Core

Connect-VIServer VSphereServer

$infile = Read-Host "Enter listpath"

$vmstores = @(#array of datastores#)

$i = 0

$list = get-content $infile

ForEach($itm in $list){
    If($i -eq $vmstores.count){$i = 0}
    $dest = $vmstores[$i]
    Move-VM $itm -datastore $dest -runasync -whatif
    $i++
}