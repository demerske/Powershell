$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"
$find.searchroot = "LDAP://OU=Servers,DC=yourdomain,DC=com"
$mask1 = 65536
$mask2 = 64
$mask3 = 2
$outfile = "$env:userprofile\desktop\localaccountreport.txt"
ri $outfile
	
Add-Content "System`tUser`tCan Change PW" -path $outfile

$list = $find.findall()
	
ForEach($itm in $list){
	$comp = [string]$itm.properties.name
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
	Else{
		$output = $comp + "`tCan't Connect to users"
		Write-Host $output
		Add-Content $output -path $outfile
	}		
}