$find = new-object system.directoryservices.directorysearcher
$team = Read-Host "Enter Team"
$file = "$env:userprofile\desktop\finalgroups2\Final-$team.xls"
$file = get-item $file

$excludes = get-content "\\shareserver\path\exemptgroups.txt"

$fname = $file.fullname
$tname = $file.name.replace("Final-","").replace(".xlsx","").replace(".xls","")
$tdname = $tname.replace("TM_","TMD_")
$fout = $fname.replace(".xlsx",".csv").replace(".xls",".csv")
$find.filter = "(&(objectcategory=group)(name=$tname))"
$team = $find.findone()
$find.filter = "(&(objectcategory=group)(name=$tdname))"
$teamd = $find.findone()
If($team -eq $null){Add-Content $tname -path "$env:userprofile\desktop\failedteams.txt"}
Else{
	$team = [string]$team.properties.distinguishedname
	$teamd = [string]$teamd.properties.distinguishedname
}

$excelapp = new-object -com Excel.Application
$excelapp.displayalerts = $false
$excelapp.visible = $false
$excelapp.workbooks.open($fname)
$sheet = $excelapp.worksheets.item(1)
$sheet.saveas($fout,6)
$excelapp.quit()
[gc]::collect()

$list = import-csv $fout

ForEach($itm in $list){
	If(($itm.comments -eq "Keep") -and ($itm.Type -eq "Security")){
		$gname = $itm.name
		$find.filter = "(&(objectcategory=group)(name=$gname))"
		$group = $find.findone()
		$gdn = [string]$group.properties.distinguishedname
		$group = [adsi]$group.path
		if($excludes -notcontains $gdn){
			$members = $group.member
			if($members -notcontains $team){
				Write-Host "$gname doesn't contain $tname"
				$members = $members + $team
				$group.member = $members
				$group.setinfo()
			}
		}
	}
}

ForEach($itm in $list){
	If(($itm.comments -eq "Keep") -and ($itm.Type -eq "distribution")){
		$gname = $itm.name
		$find.filter = "(&(objectcategory=group)(name=$gname))"
		$group = $find.findone()
		$gdn = [string]$group.properties.distinguishedname
		$group = [adsi]$group.path
		if($excludes -notcontains $gdn){
			$members = $group.member
			if($members -notcontains $teamd){
				Write-Host "$gname doesn't contain $tdname"
				$members = $members + $teamd
				$group.member = $members
				$group.setinfo()
			}
		}
	}
}

ri $fout
clv list

Taskkill /F /IM Excel.exe