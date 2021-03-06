$input = Read-Host "Enter input file"
$outfile = Read-Host "Enter output filepath"
$systems = Get-Content $input
ForEach($system in $systems){
	$adapters = gwmi Win32_networkadapterconfiguration -computer $system
	if($error[0].exception -ne $null){
		$output = $system + "`t" + $error[0].exception.message.tostring()
		Write-Host $output
		Add-Content $output -path $outfile
		$error.clear()
	}
	Else{
		ForEach($adapter in $adapters){
			if($adapter.ipenabled -eq "true"){
				$output = $system + "`t" + $adapter.description + "`t" + $adapter.macaddress + "`t" + $adapter.IPAddress
				Write-Host $output
				Add-Content $output -path $outfile
			}
		}
	}
}