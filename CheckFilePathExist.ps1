$paths = get-content "$env:userprofile\desktop\filepaths.txt"

ForEach($itm in $paths){
	$chk = test-path $itm
	If($chk -eq $true){$output = $itm + "`tExists"}
	If($chk -eq $false){$output = $itm + "`tNotExist"}
	Write-Host $output 
	Add-Content $output -path "$env:userprofile\desktop\filepathcheck.txt"
}