$outfile = "$env:userprofile\desktop\javaversionid.txt"
ri $outfile
$error.clear()

$systems = get-content "c:\Scripting\txt\list.txt"
foreach($system in $systems){
	$serverkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::ClassesRoot,$system)
	If($error[0].exception -ne $null){
		$output = $system + "`t" + $error[0].exception.message.tostring()
		Write-host $output
		Add-Content $output -path $outfile
		$error.clear()
	}
	Else{
		$javakey = $serverkey.opensubkey("CLSID\{8AD9C840-044E-11D1-B3E9-00805F499D93}")
		If($javakey -eq $null){$output = $system + "`tKey Not Found"}
		ElseIf($javakey -ne $null){
			$version = $javakey.getvalue("")
			$output = $system + "`t" + $version
		}
		Write-Host $output
		Add-Content $output -path $outfile
	}
}
