Add-PSSnapin VMWare.VIMAutomation.Core

Connect-VIServer VSphereServer

$vmclus = Read-Host "Enter Clustername"
$oldnet = Read-Host "Enter Old Network Name"
$newnet = Read-Host "Enter New Network Name"

$vmhostsget = get-vmhost | ?{$_.parent.name -eq $vmclus}
foreach($a in $vmhostsget){[array]$vmhosts = $vmhosts + $a.name}

ForEach($vmhost in $vhosts){
    $list = get-vm -location $vmhost
    ForEach($itm in $list){
        Write-Host $itm.name
        get-networkadapter -vm $itm | ?{$_.networkname -eq $oldnet} | set-networkadapter -networkname $newnet -WhatIf
    }
}