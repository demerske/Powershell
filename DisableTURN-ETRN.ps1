$erroractionpreference = "SilentlyContinue"
$error.clear()
$TURN = 0x400
$ETRN = 0x80
$setvalue = "7696449"

$Path = Read-Host "Enter path to list file"
$outfile = Read-Host "Enter log path"
$systems = get-content $path

ForEach($system in $systems){
	$ping = test-connection $system -quiet
	$error.clear()
	If($ping -eq $false){
		$output = $system + "`tUnreachable"
		Write-Host $output
		Add-Content $output -path $outfile
	}
	ElseIf($ping -eq $true){
		$con = [adsi] "IIS://$system/smtpsvc/1"
		$value = $con.smtpinboundcommandsupportoptions.tostring()
		If($error[0] -ne $null){
			$output = $system + "`t" + $error[0].exception.message.tostring()
			Write-Host $output
			Add-Content $output -path $outfile
			$error.clear()
		}
		Elseif($error[0] -eq $null){
			If($value -eq "7697601"){
				$con.smtpinboundcommandsupportoptions = $setvalue
				$con.setinfo()
				If($error[0] -eq $null){
					$output = $system + "`tSuccess"
				}
				ElseIf($error[0] -ne $null){
					$output = $system + "`tFailed`t" + $error[0].exception.message.tostring()
				}
				Write-Host $output
				Add-Content $output -path $outfile
				$error.clear()
			}
		}
	}
}