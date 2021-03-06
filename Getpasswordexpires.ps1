$Path = Read-Host "Enter Listfile Path"
$outfile = Read-Host "Enter outfile path"
$systems = Get-content $path

ForEach($system in $systems){$accounts = gwmi Win32_useraccount -computer $system -filter "localaccount='true'"
	ForEach($account in $accounts){$output = $system + "`t" + $account.name + "`t" + $account.passwordexpires
		Write-Host $output
		Add-Content $output -path $outfile
	}
}