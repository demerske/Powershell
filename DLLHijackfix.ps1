$path = Read-Host "Enter path to list file"
$outfile = Read-Host "Enter output file"

$list = get-content $path
$i = $list.count

ForEach($itm in $list){
	If((test-connection $itm -quiet -count 2) -eq $true){
		$error.clear()
		$serverkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$itm)
		$sub = $serverkey.opensubkey("system\currentcontrolset\control\session manager",$true)
		$sub.setvalue("SafeDllSearchMode","1","dword")
		$sub.setvalue("CWDIllegalInDLLSearch","1","dword")
		if($error[0] -ne $null){
			$output = $itm + "`t" + $error[0].exception.message.tostring()
			Write-Host $output $i
			Add-Content $output -path $outfile
			$error.clear()
		}
		Else{
			$output = $itm + "`tSuccess"
			Write-Host $output $i
			add-content $output -path $outfile
		}
	}
	Else{
		$output = $itm + "`tOffline"
		Write-Host $output $i
		Add-Content $output -path $outfile
	}
	$i = $i - 1
}

Write-Host "Log is $outfile"