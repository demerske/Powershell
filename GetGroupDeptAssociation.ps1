$find = new-object system.directoryservices.directorysearcher
$find.searchroot = #LDAP connection to search
$find.filter = "(objectcategory=group)"
ri "c:\scripting\output\groupdepts.txt"
mkdir $env:temp\deptinfo
ri $env:temp\deptinfo\* -recurse -force

$list = $find.findall()

ForEach($itm in $list){
	$itm = [adsi]$itm.path
	$name = [string]$itm.name
	$members = $itm.member
	If($members.count -ne 0){
		ForEach($mem in $members){
			$mem = [adsi]"LDAP://$mem"
			$dept = [string]$mem.departmentnumber
			$mgr = $mem.manager
			$mgr = ([adsi]"LDAP://$mgr").name
			Add-Content $mgr -path "$env:temp\deptinfo\mgr-$name.txt"
			$dept = $dept.substring(0,2)
			Add-Content $dept -path "$env:temp\deptinfo\$name.txt"
		}
		$depts = get-content "$env:temp\deptinfo\$name.txt"
		$depts = $depts | Select -unique
		$mgrs = get-content "$env:temp\deptinfo\mgr-$name.txt"
		$mgrs = $mgrs | Select -unique
		$mgrs = [system.string]::Join("; ",$mgrs)
		$depts = [system.string]::Join("; ",$depts)
		$output = $name + "`t" + $depts + "`t" + $mgrs
		Write-Host $output
		Add-Content $output -path "c:\scripting\output\groupdepts.txt"
	}
}