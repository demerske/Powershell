$comp = "system.yourdomain.com"
$outfile = "c:\scripting\output\$comp.txt"
$mask1 = 65536
$mask2 = 64
$mask3 = 2
$users = ([adsi]"WinNT://$comp").psbase.children | ?{$_.SchemaClassName -match "user"}
If($users -ne $null){
	ForEach($user in $users){
		$flags = $user.userflags.value
		$uname = $user.name
		$disabled = $flags -band $mask3
		If($disabled -eq $mask3){
			$output = $comp + "`t" + $uname + "`tAccount Disabled`t$domain"
			Write-Host $output
			Add-Content $output -path $outfile
		}
		Else{
			$test1 = $flags -band $mask1
			If($test1 -eq $mask1){
				$test2 = $flags -band $mask2
				If($test2 -eq 0){$pwdchg = "Can Change (Flipped)"
                    $nflags = $flags -bxor $mask2
                    $user.userflags.value = $nflags
                    $user.setinfo()
                }
				Else{$pwdchg = "Cannot Change"}
				$output = $comp + "`t" + $uname + "`t" + $pwdchg + "`t" + $domain
				Write-Host $output
				Add-Content $output -path $outfile
			}
			Else{
				$output = $comp + "`t" + $uname + "`tPW Expires`t$domain"
				Write-Host $output
				Add-Content $output -path $outfile
			}
		}
	}
}