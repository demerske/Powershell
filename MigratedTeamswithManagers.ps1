$get = "$env:userprofile\desktop\remaininggroups.txt"
$temp = import-csv $get -delimiter "`t"
ri "$env:userprofile\desktop\temp\*.txt"

ForEach($a in $temp){
	$at = $a.team
	$b = $a.manager.replace(", ",",")
	$b = $b.split(",")
	$c = $b[1] + " " + $b[0]
	Add-Content $c -path "$env:userprofile\desktop\temp\$at.txt"
}

$files = gci "$env:userprofile\desktop\temp"

ForEach($file in $files){
	$team = $file.name.replace(".txt","")
	$file = $file.fullname
	$data = get-content $file
	If($data.count -ne $null){
		$string = [system.string]::Join(", ",$data)
		$output = $team + "`t" + $string
		Write-Host $output
		Add-Content $output -path "$env:userprofile\desktop\mig.txt"
	}
	Else{
		$output = $team + "`t" + $data
		Write-Host $output
		Add-Content $output -path "$env:userprofile\desktop\mig.txt"
	}
}