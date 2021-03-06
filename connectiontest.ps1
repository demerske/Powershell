$list = get-content "$env:userprofile\desktop\list.txt"
$error.clear()
ForEach($itm in $list){
	$ping = test-connection $itm -quiet -count 2
	if($ping -eq $true){$wmi = gwmi win32_bios
		if($error -ne $null){$wmi = $error[0].exception.message.tostring()
			$error.clear()
		}
		Else{$wmi = "Pass"}
	}
	$output = $itm + "`t" + $ping + "`t" + $wmi
	clv wmi
	$error.clear()
	Write-Host $output
	Add-Content $output -path "$env:userprofile\desktop\connectionissues.txt"
}