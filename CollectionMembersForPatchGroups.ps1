$pref = "Software Updates - Servers "
$colls = @(#Array of patch groups)

ForEach($itm in $colls){
    $colln = $pref + $itm
    ri "d:\reports\Computer Groups\$colln.txt"
    $a = gwmi -computer SCCMServer -namespace "Root\SMS\site_NAME" -query "Select CollectionID FROM SMS_Collection WHERE Name='$colln'"
    $coll = $a.collectionid
    $coll = "SMS_CM_RES_COLL_" + $coll
    $b = gwmi $coll -computer SCCMServer -namespace "Root\SMS\Site_NAME"
    
    ForEach($s in $b){
        $name = $s.name
        Add-Content $name -path "d:\reports\Computer Groups\$colln.txt"
    }
}