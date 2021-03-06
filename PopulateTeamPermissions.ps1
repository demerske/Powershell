$find = new-object system.directoryservices.directorysearcher

$files = gci "$env:userprofile\desktop\finalgroups2"
$excludes = get-content "\\shareserver\path\exemptgroups.txt"

ForEach($file in $files){
	$fname = $file.fullname
	$tname = $file.name.replace("Final-","").replace(".xlsx","").replace(".xls","")
	$fout = $fname.replace(".xlsx",".csv").replace(".xls",".csv")
	$find.filter = "(&(objectcategory=group)(name=$tname))"
	$team = $find.findone()
	If($team -eq $null){Add-Content $tname -path "$env:userprofile\desktop\failedteams.txt"}
	Else{$team = [string]$team.properties.distinguishedname
		
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
			If($itm.comments -eq "Keep"){
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
	}
	ri $fout
}