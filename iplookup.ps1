$path = Read-Host "Enter listfile"
$outfile = Read-Host "Enter output filepath"
$systems = Get-Content $path
ForEach($system in $systems){
	$ip = [System.Net.DNS]::GetHostAddresses("$system")
	If($error[0].exception -ne $null){
		$output = $system + "`t" + $error[0].exception.message.tostring()
		Write-Host $output 
		Add-Content $output -path $outfile
		$error.clear()
	}
	ElseIf($error[0].exception -eq $null){
		$output = $system + "`t" + $ip
		Write-Host $output
	    Add-Content $output -path $outfile
	}
}