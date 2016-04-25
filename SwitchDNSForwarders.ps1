$list = get-content "c:\scripting\txt\list.txt"
$uips = "#DNS Servers space separated e.g. 10.0.0.1 10.0.0.2 10.10.0.3"

ForEach($itm in $list){
    $cmd = "c:\windows\system32\dnscmd.exe $itm /resetforwarders " + $uips
    Invoke-Expression -command $cmd
}