$Path = "$env:userprofile\desktop\testmachines.txt"
$safelist = @("safe", "username", "array", "here")
$systems = Get-content $path
$ADS_UF_DONT_EXPIRE_PASSWD = 0x10000
ForEach($system in $systems){
	$comp = [adsi] "WinNT://$system"
	$users = $comp.psbase.children | ?{$_.SchemaClassName -match "user"}
	ForEach($user in $users){
		if($safelist -contains $user.Name){
			$a = $user.userflags.tostring()
			$c = $a -band $ADS_UF_DONT_EXPIRE_PASSWD
			if($c -ne 0){
				$user.userflags = $user.userflags[0] -bxor $ADS_UF_DONT_EXPIRE_PASSWD
				$user.setinfo()
				If($error[0] -ne $Null){Write-Host $user.name
					$error.clear()
				}
			}
		}
	}
}