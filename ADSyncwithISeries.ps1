$find = new-object system.directoryservices.directorysearcher

$header = "Clock`tPartition`tUsers"
ri $env:temp\finalout.txt
Add-Content $header -path $env:temp\finalout.txt


$list = get-content "$env:userprofile\desktop\clock_report.txt"
$list = $list | Select -unique
ri $env:temp\temp.txt
Add-Content $list -path $env:temp\temp.txt
$list = import-csv $env:temp\temp.txt
$list = $list | Where-Object{$_.user -ne $null}

mkdir $env:temp\iseries
ri $env:temp\iseries\*

ForEach($itm in $list){
	$clock = $itm.clock
	$part = $itm."partition ".trim()
	$user = $itm.user.trim()
	Add-Content $user -path $env:temp\iseries\$clock-$part.txt
}

$files = gci $env:temp\iseries

ForEach($file in $files){
	$a = $file.name
	$a = $a.replace(".txt","").split("-")
	$clock = $a[0]
	$part = $a[1]
	$names = get-content $file.fullname
	If($names.count -eq $null){$output = $clock + "`t" + $part + "`t" + $names}
	Else{
		$end = $names.count - 1
		$i = 0
		While($i -le $end){
			$ulist = $ulist + "," + $names[$i]
			$i++
		}
		$ulist = $ulist.substring(1,$ulist.length -1)
		$output = $clock + "`t" + $part + "`t" + $ulist
	}
	clv ulist
	Write-Host $output
	Add-Content $output -path $env:temp\finalout.txt
}

$list = import-csv $env:temp\finalout.txt -delimiter `t

ForEach($itm in $list){
	$clock = $itm.clock
	$find.filter = "(&(objectcategory=user)(employeeid=$clock))"
	$users = $find.findall()
	ForEach($user in $users){
		$user = [adsi]$user.path
		$user.putex(1,"businesscategory",0)
		$user.setinfo()
		$user = [adsi]$user.path
		$user.businesscategory.add($itm.users)
		$user.setinfo()
	}
}