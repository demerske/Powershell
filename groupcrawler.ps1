$erroractionpreference = "SilentlyContinue"
$error.clear()


$fname = Read-Host "Enter First Name of target user"
$lname = Read-Host "Enter Last Name of target user"
$yourname = Read-Host "Enter your logon name"
$result = Test-Path "c:\users\$yourname"
If($result -eq $True){$prefix = "c:\users\$yourname\desktop\groupscript"}
Else{$prefix = "c:\documents and settings\$yourname\desktop\groupscript"}
$result = Test-Path $prefix
If($result -ne $true){mkdir $prefix}

$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(givenname=$fname)(sn=$lname))"

$list = $find.findall()

If($list -ne $null){
	ForEach($itm in $list){
		$logon = $itm.properties.samaccountname
		$outfile = "$prefix\$fname-$lname-$logon.txt"
		Remove-Item "$env:temp\sub*.txt"
		remove-item $outfile
		$error.clear()
		
		$membership = $itm.properties.memberof
		
		ForEach($grp in $membership){
			$a = $grp.split(",")
			$grp = $a[0]
			$grp = $grp.replace("CN=","")
			$grps = $grps + $grp
			Add-Content $grp -path $outfile}
		
		$list1 = Get-Content $outfile
		
		$i = 1
		
		While($i -le 10){
			ForEach($itm1 in $list1){
				$find.filter = "(name=$itm1)"
				$itm1 = $find.findone()
				
				If($itm1 -ne $null){
					$name = [string] $itm1.properties.name
					$memberof = $itm1.properties.memberof
					
					If($memberof -ne $null){
						ForEach($grp in $memberof){
							$a = $grp.split(",")
							$grp = $a[0]
							$grp = $grp.replace("CN=","")
							Add-Content $grp -path $outfile
							Add-Content $grp -path "$env:temp\sub$i.txt"
						}
					}
				}
			}
			$list1 = Get-Content "$env:temp\sub$i.txt"
			$i++
		}
		
		$unique = Get-Content $outfile
		$unique = $unique | Select -unique
		Remove-Item $outfile
		ForEach($line in $unique){
			$exempt = "path to exempted groups text list file"
			If($exempt -notcontains $line){
				Add-Content $line -path $outfile
			}
		}
	}
}

Write-Host "Output is in $prefix"