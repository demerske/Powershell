$pref = "Software Updates - Servers "
$colls = @(#array of SCCM Collections to query#)



	$loop = $true
	while($loop -eq $true){
		Remove-Variable a1
		Write-Host "Select Collection"
		$i = 0
		while($i -le ($colls.count - 1)){
            $option = [string]$i + ":- " + $pref + $colls[$i]
			Write-Host $option
			$i++
		}
		[int]$a1 = Read-Host "Selection:"
		If(($a1 -is [int]) -and ($a1 -le ($colls.count -1))){$colln = [string]$pref + $colls[$a1]
			$loop = $false
		}
	}
    
$a = gwmi -computer OMASCCMPRD01 -namespace "Root\SMS\site_NAME" -query "Select CollectionID FROM SMS_Collection WHERE Name='$colln'"
$coll = $a.collectionid
$coll = "SMS_CM_RES_COLL_" + $coll
$b = gwmi $coll -computer OMASCCMPRD01 -namespace "Root\SMS\site_NAME"

ForEach($s in $b){
    $name = $s.name
    Add-Content $name -path "d:\reports\Computer Groups\$colln.txt"
}

$b | Out-Gridview