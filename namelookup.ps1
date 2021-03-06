$path = Read-Host "Enter listfile"
$outfile = Read-Host "Enter output filepath"
$systems = Get-Content $path
ForEach($system in $systems){
	$name = [System.Net.DNS]::GetHostbyAddress($system)
	If($error[0].exception -ne $Null){
		$output = $system + "`t" + $error[0].exception.message.tostring()
		Add-Content $output -path $outfile
		$error.clear()
	}
	Else{
		$output = $system + "`t" + $name.hostname
		Add-Content $output -path $outfile
	}
}