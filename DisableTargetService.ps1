$input = Read-Host "Enter list file (I.E. c:\users\userabc\desktop\list.txt)"
$tsvc = Read-Host "Enter service name"
$id = Read-Host "Enter NTID"
$list = get-content $input
$error.clear()

ForEach($itm in $list){
	$svc = gwmi Win32_Service -filter "name='$tsvc'" -computer $itm
	If($error[0] -ne $null){
		$output = $itm + "`t" + $error[0].exception.message.tostring()
		$error.clear()
	}
	Else{
		$disable = $svc.changestartmode("Disabled").returnvalue
		$stopsvc = $svc.stopservice().returnvalue
		If($disable -ne 0){$output = $itm + "`tDisable Service Failed"}
		Elseif($stopsvc -ne 0){$output = $itm + "`tStop Service Failed"}
		Else{$output = $itm + "`tSuccess"}
		Write-Host $output
		Add-Content $output -path "c:\users\$id\desktop\DisableTargetServiceLog.txt"
	}
}